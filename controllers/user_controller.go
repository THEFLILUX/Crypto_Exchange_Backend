package controllers

import (
	"Toy_Cryptocurrency/configs"
	"Toy_Cryptocurrency/functions"
	"Toy_Cryptocurrency/models"
	"Toy_Cryptocurrency/responses"
	"context"
	"crypto"
	"crypto/rand"
	"crypto/rsa"
	"crypto/sha256"
	"crypto/tls"
	"crypto/x509"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
	"runtime"
	"time"

	"github.com/go-playground/validator/v10"
	"github.com/gorilla/mux"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"gopkg.in/gomail.v2"
)

var userCollection = configs.GetCollection(configs.DB, "Users")
var validateUser = validator.New()

func SendSecurityCodeLogin() http.HandlerFunc {
	return func(writer http.ResponseWriter, request *http.Request) {
		writer.Header().Set("Content-Type", "application/json; charset=utf-8")
		ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		var user models.User
		defer cancel()

		// Validar que el body está en formato JSON
		if err := json.NewDecoder(request.Body).Decode(&user); err != nil {
			writer.WriteHeader(http.StatusBadRequest)
			response := responses.UserResponse{
				Status:  http.StatusBadRequest,
				Message: "Formato del contenido de la solicitud no válido",
				Data:    err.Error(),
			}
			_ = json.NewEncoder(writer).Encode(response)
			return
		}

		// Se usa la librería para validar los campos del body
		if validationErr := validateUser.Struct(&user); validationErr != nil {
			writer.WriteHeader(http.StatusBadRequest)
			response := responses.UserResponse{
				Status:  http.StatusBadRequest,
				Message: "Campos del contenido de la solicitud no válidos",
				Data:    validationErr.Error(),
			}
			_ = json.NewEncoder(writer).Encode(response)
			return
		}

		// Verificar que el usuario ya esté registrado
		var tempUser models.User
		err := userCollection.FindOne(ctx, bson.M{"email": user.Email}).Decode(&tempUser)
		if err != nil {
			writer.WriteHeader(http.StatusInternalServerError)
			response := responses.UserResponse{
				Status:  http.StatusInternalServerError,
				Message: "Usuario no registrado",
				Data:    "Usuario no registrado",
			}
			_ = json.NewEncoder(writer).Encode(response)
			return
		}

		// Verificar que la contraseña sea correcta
		if tempUser.Password != user.Password {
			writer.WriteHeader(http.StatusInternalServerError)
			response := responses.UserResponse{
				Status:  http.StatusInternalServerError,
				Message: "Contraseña incorrecta",
				Data:    "Contraseña incorrecta",
			}
			_ = json.NewEncoder(writer).Encode(response)
			return
		}

		// Crear imagen y txt con el código de seguridad
		errorCode, securityCodeUserImageRoute := functions.CreateSecurityCode(user)
		if errorCode != 0 {
			writer.WriteHeader(http.StatusInternalServerError)
			response := responses.UserResponse{
				Status:  http.StatusInternalServerError,
				Message: "Error al generar el código de seguridad",
				Data:    fmt.Sprintf("Error al generar el código de seguridad %d", errorCode),
			}
			_ = json.NewEncoder(writer).Encode(response)
			return
		}

		// Enviar correo con el código de verificación
		message := gomail.NewMessage()
		message.SetHeader("From", message.FormatAddress("toy.cryptocurrency@outlook.com", "Toy Cryptocurrency"))
		message.SetHeader("To", user.Email)
		message.SetHeader("Subject", "Código de autorización Toy Cryptocurrency")
		emailContent := "<p>Hola <b>" + tempUser.Email + "</b>,</p><p>Tu código de verificación se encuentra adjunto como imagen en este correo.</p><p>No compartas este código con nadie.</p><p><b>Equipo de Toy Cryptocurrency</b></p>"
		message.SetBody("text/html", emailContent)
		message.Attach(securityCodeUserImageRoute)
		dialer := gomail.NewDialer("smtp-mail.outlook.com", 587, "toy.cryptocurrency@outlook.com", "SanJuan1603")
		dialer.TLSConfig = &tls.Config{InsecureSkipVerify: true}
		if err := dialer.DialAndSend(message); err != nil {
			writer.WriteHeader(http.StatusInternalServerError)
			response := responses.UserResponse{
				Status:  http.StatusInternalServerError,
				Message: "Error al generar el código de seguridad 4",
				Data:    "Error al generar el código de seguridad",
			}
			_ = json.NewEncoder(writer).Encode(response)
			return
		}

		writer.WriteHeader(http.StatusOK)
		response := responses.UserResponse{
			Status:  http.StatusOK,
			Message: "Código de seguridad enviado al correo electrónico",
			Data:    "Código de seguridad enviado al correo electrónico",
		}
		_ = json.NewEncoder(writer).Encode(response)
		fmt.Printf("Código de verificación del usuario %s ha sido enviado\n", tempUser.Email)
	}
}

func VerifySecurityCodeLogin() http.HandlerFunc {
	return func(writer http.ResponseWriter, request *http.Request) {
		writer.Header().Set("Content-Type", "application/json; charset=utf-8")
		ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		params := mux.Vars(request)
		securityCode := params["securityCode"]
		var user models.User
		defer cancel()

		// Validar que el body está en formato JSON
		if err := json.NewDecoder(request.Body).Decode(&user); err != nil {
			writer.WriteHeader(http.StatusBadRequest)
			response := responses.UserResponse{
				Status:  http.StatusBadRequest,
				Message: "Formato del contenido de la solicitud no válido",
				Data:    err.Error(),
			}
			_ = json.NewEncoder(writer).Encode(response)
			return
		}

		// Leer código de archivo txt
		securityCodeTxtRoute := ""
		if runtime.GOOS == "windows" {
			securityCodeTxtRoute = "security_codes/users_codes_texts/" + user.Email + ".txt"
		} else {
			securityCodeTxtRoute = "/app/security_codes/users_codes_texts/" + user.Email + ".txt"
		}
		securityCodeFile, err := ioutil.ReadFile(securityCodeTxtRoute)
		if err != nil {
			writer.WriteHeader(http.StatusInternalServerError)
			response := responses.UserResponse{
				Status:  http.StatusInternalServerError,
				Message: "No se ha solicitado código de seguridad",
				Data:    "No se ha solicitado código de seguridad",
			}
			_ = json.NewEncoder(writer).Encode(response)
			return
		}

		// Verificar código de seguridad
		if securityCode != string(securityCodeFile) {
			writer.WriteHeader(http.StatusInternalServerError)
			response := responses.UserResponse{
				Status:  http.StatusInternalServerError,
				Message: "Código de seguridad incorrecto",
				Data:    "Código de seguridad incorrecto",
			}
			_ = json.NewEncoder(writer).Encode(response)
			return
		}

		// Eliminar archivos con códigos de seguridad
		securityCodeImageRoute := ""
		if runtime.GOOS == "windows" {
			securityCodeImageRoute = "security_codes/users_codes_images/" + user.Email + ".png"
		} else {
			securityCodeImageRoute = "/app/security_codes/users_codes_images/" + user.Email + ".png"
		}
		_ = os.Remove(securityCodeTxtRoute)
		err = os.Remove(securityCodeImageRoute)

		// Si no están los archivos, significa que no se ha solicitado un código de seguridad
		if err != nil {
			writer.WriteHeader(http.StatusInternalServerError)
			response := responses.UserResponse{
				Status:  http.StatusInternalServerError,
				Message: "No se ha solicitado código de seguridad",
				Data:    "No se ha solicitado código de seguridad",
			}
			_ = json.NewEncoder(writer).Encode(response)
			return
		}

		// Extraer datos del usuario de la base de datos
		var dbUser models.User
		_ = userCollection.FindOne(ctx, bson.M{"email": user.Email}).Decode(&dbUser)

		// Se retorna los campos del usuario autenticado
		writer.WriteHeader(http.StatusOK)
		response := responses.UserResponse{
			Status:  http.StatusOK,
			Message: "Usuario logeado con éxito",
			Data: models.User{
				Id:         dbUser.Id,
				FirstName:  dbUser.FirstName,
				LastName:   dbUser.LastName,
				Country:    dbUser.Country,
				Email:      dbUser.Email,
				Password:   "",
				PublicKey:  dbUser.PublicKey,
				PrivateKey: dbUser.PrivateKey,
			},
		}
		_ = json.NewEncoder(writer).Encode(response)
		fmt.Printf("Código verificado, usuario %s logeado con éxito\n", user.Email)
	}
}

func SendSecurityCodeRegister() http.HandlerFunc {
	return func(writer http.ResponseWriter, request *http.Request) {
		writer.Header().Set("Content-Type", "application/json; charset=utf-8")
		ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		var user models.User
		defer cancel()

		// Validar que el body está en formato JSON
		if err := json.NewDecoder(request.Body).Decode(&user); err != nil {
			writer.WriteHeader(http.StatusBadRequest)
			response := responses.UserResponse{
				Status:  http.StatusBadRequest,
				Message: "Formato del contenido de la solicitud no válido",
				Data:    err.Error(),
			}
			_ = json.NewEncoder(writer).Encode(response)
			return
		}

		// Se usa librería para validar los campos del body
		if validationErr := validateUser.Struct(&user); validationErr != nil {
			writer.WriteHeader(http.StatusBadRequest)
			response := responses.UserResponse{
				Status:  http.StatusBadRequest,
				Message: "Campos del contenido de la solicitud no válidos",
				Data:    validationErr.Error(),
			}
			_ = json.NewEncoder(writer).Encode(response)
			return
		}

		// Verificar que el usuario no esté registrado en la base de datos
		var tempUser models.User
		err := userCollection.FindOne(ctx, bson.M{"email": user.Email}).Decode(&tempUser)
		if err == nil {
			writer.WriteHeader(http.StatusInternalServerError)
			response := responses.UserResponse{
				Status:  http.StatusInternalServerError,
				Message: "Usuario ya existente",
				Data:    "Usuario ya existente",
			}
			_ = json.NewEncoder(writer).Encode(response)
			return
		}

		// Crear imagen y txt con el código de seguridad
		errorCode, securityCodeUserImageRoute := functions.CreateSecurityCode(user)
		if errorCode != 0 {
			writer.WriteHeader(http.StatusInternalServerError)
			response := responses.UserResponse{
				Status:  http.StatusInternalServerError,
				Message: "Error al generar el código de seguridad",
				Data:    fmt.Sprintf("Error al generar el código de seguridad %d", errorCode),
			}
			_ = json.NewEncoder(writer).Encode(response)
			return
		}

		// Enviar correo con el código de verificación
		message := gomail.NewMessage()
		message.SetHeader("From", message.FormatAddress("toy.cryptocurrency@outlook.com", "Toy Cryptocurrency"))
		message.SetHeader("To", user.Email)
		message.SetHeader("Subject", "Código de autorización Toy Cryptocurrency")
		emailContent := "<p>Hola <b>" + user.Email + "</b>,</p><p>Tu código de verificación se encuentra adjunto como imagen en este correo.</p><p>No compartas este código con nadie.</p><p><b>Equipo de Toy Cryptocurrency</b></p>"
		message.SetBody("text/html", emailContent)
		message.Attach(securityCodeUserImageRoute)
		dialer := gomail.NewDialer("smtp-mail.outlook.com", 587, "toy.cryptocurrency@outlook.com", "SanJuan1603")
		if err := dialer.DialAndSend(message); err != nil {
			writer.WriteHeader(http.StatusInternalServerError)
			response := responses.UserResponse{
				Status:  http.StatusInternalServerError,
				Message: "Error al generar el código de seguridad 4",
				Data:    "Error al generar el código de seguridad",
			}
			_ = json.NewEncoder(writer).Encode(response)
			return
		}

		writer.WriteHeader(http.StatusOK)
		response := responses.UserResponse{
			Status:  http.StatusOK,
			Message: "Código de seguridad enviado al correo electrónico",
			Data:    "Código de seguridad enviado al correo electrónico",
		}
		_ = json.NewEncoder(writer).Encode(response)
		fmt.Printf("Código de verificación del usuario %s ha sido enviado\n", user.Email)
	}
}

func VerifySecurityCodeRegister() http.HandlerFunc {
	return func(writer http.ResponseWriter, request *http.Request) {
		writer.Header().Set("Content-Type", "application/json; charset=utf-8")
		ctx, cancel := context.WithTimeout(context.Background(), 1*time.Minute)
		params := mux.Vars(request)
		securityCode := params["securityCode"]
		var user models.User
		defer cancel()

		// Validar que el body está en formato JSON
		if err := json.NewDecoder(request.Body).Decode(&user); err != nil {
			writer.WriteHeader(http.StatusBadRequest)
			response := responses.UserResponse{
				Status:  http.StatusBadRequest,
				Message: "Formato del contenido de la solicitud no válido",
				Data:    err.Error(),
			}
			_ = json.NewEncoder(writer).Encode(response)
			return
		}

		// Leer código de archivo txt
		securityCodeTxtRoute := ""
		if runtime.GOOS == "windows" {
			securityCodeTxtRoute = "security_codes/users_codes_texts/" + user.Email + ".txt"
		} else {
			securityCodeTxtRoute = "/app/security_codes/users_codes_texts/" + user.Email + ".txt"
		}
		securityCodeFile, err := ioutil.ReadFile(securityCodeTxtRoute)
		if err != nil {
			writer.WriteHeader(http.StatusInternalServerError)
			response := responses.UserResponse{
				Status:  http.StatusInternalServerError,
				Message: "No se ha solicitado código de seguridad",
				Data:    "No se ha solicitado código de seguridad",
			}
			_ = json.NewEncoder(writer).Encode(response)
			return
		}

		// Verificar código de seguridad
		if securityCode != string(securityCodeFile) {
			writer.WriteHeader(http.StatusInternalServerError)
			response := responses.UserResponse{
				Status:  http.StatusInternalServerError,
				Message: "Código de seguridad incorrecto",
				Data:    "Código de seguridad incorrecto",
			}
			_ = json.NewEncoder(writer).Encode(response)
			return
		}

		// Eliminar archivos con códigos de seguridad
		securityCodeImageRoute := ""
		if runtime.GOOS == "windows" {
			securityCodeImageRoute = "security_codes/users_codes_images/" + user.Email + ".png"
		} else {
			securityCodeImageRoute = "/app/security_codes/users_codes_images/" + user.Email + ".png"
		}
		_ = os.Remove(securityCodeTxtRoute)
		err = os.Remove(securityCodeImageRoute)

		// Si no están los archivos, significa que no se ha solicitado un código de seguridad
		if err != nil {
			writer.WriteHeader(http.StatusInternalServerError)
			response := responses.UserResponse{
				Status:  http.StatusInternalServerError,
				Message: "No se ha solicitado código de seguridad",
				Data:    "No se ha solicitado código de seguridad",
			}
			_ = json.NewEncoder(writer).Encode(response)
			return
		}

		// Crear llaves pública y privada
		privateKey, err := rsa.GenerateKey(rand.Reader, 2048)
		if err != nil {
			writer.WriteHeader(http.StatusInternalServerError)
			response := responses.UserResponse{
				Status:  http.StatusInternalServerError,
				Message: "Error al generar la llave privada",
				Data:    err.Error(),
			}
			_ = json.NewEncoder(writer).Encode(response)
			return
		}
		publicKey := &privateKey.PublicKey

		// Convertir llaves a string
		privateKeyString := base64.StdEncoding.EncodeToString(x509.MarshalPKCS1PrivateKey(privateKey))
		publicKeyString := base64.StdEncoding.EncodeToString(x509.MarshalPKCS1PublicKey(publicKey))

		// Crear modelo de usuario con sus campos completos
		newUser := models.User{
			Id:         primitive.NewObjectID(),
			FirstName:  user.FirstName,
			LastName:   user.LastName,
			Country:    user.Country,
			Email:      user.Email,
			Password:   user.Password,
			PublicKey:  publicKeyString,
			PrivateKey: privateKeyString,
		}
		_, err = userCollection.InsertOne(ctx, newUser)
		if err != nil {
			writer.WriteHeader(http.StatusInternalServerError)
			response := responses.UserResponse{
				Status:  http.StatusInternalServerError,
				Message: "Error al registrar el nuevo usuario",
				Data:    err.Error(),
			}
			_ = json.NewEncoder(writer).Encode(response)
			return
		}

		// Zona horaria de Perú
		timeZone, _ := time.LoadLocation("America/Lima")

		// Si la collección no existe, crear el primer bloque
		count, _ := blockCollection.CountDocuments(ctx, bson.M{})
		if count == 0 {
			firstBlock := models.Block{
				Id:           primitive.NewObjectID(),
				Index:        1,
				PreviousHash: "0",
				Proof:        0,
				Timestamp:    time.Now().In(timeZone),
				Miner:        "0",
				Signature:    "0",
				Transaction: models.Transaction{
					From:   "0",
					To:     "0",
					Amount: 0.0,
					Fee:    0.0,
				},
			}

			// Se inserta nuevo bloque en la base de datos
			_, err = blockCollection.InsertOne(ctx, firstBlock)
			if err != nil {
				writer.WriteHeader(http.StatusInternalServerError)
				response := responses.BlockResponse{
					Status:  http.StatusInternalServerError,
					Message: "Error al insertar el primer bloque en la cadena",
					Data:    err.Error(),
				}
				_ = json.NewEncoder(writer).Encode(response)
				return
			}

			// Se inserta nuevo bloque en la base de datos (réplica)
			//_, err = blockCollectionReplica.InsertOne(ctx, firstBlock)
			if err != nil {
				// Se elimina el bloque insertado en la base de datos inicial
				_, _ = blockCollection.DeleteOne(ctx, bson.M{"_id": firstBlock.Id})

				writer.WriteHeader(http.StatusInternalServerError)
				response := responses.BlockResponse{
					Status:  http.StatusInternalServerError,
					Message: "Error al insertar el primer bloque en la cadena",
					Data:    err.Error(),
				}
				_ = json.NewEncoder(writer).Encode(response)
				return
			}
		}

		// Obtener cadena de bloques de la base de datos
		var blocks []models.Block
		results, err := blockCollection.Find(ctx, bson.M{})
		if err != nil {
			writer.WriteHeader(http.StatusInternalServerError)
			response := responses.BlockResponse{
				Status:  http.StatusInternalServerError,
				Message: "Error al leer la base de datos",
				Data:    err.Error(),
			}
			_ = json.NewEncoder(writer).Encode(response)
			return
		}
		defer func(results *mongo.Cursor, ctx context.Context) {
			_ = results.Close(ctx)
		}(results, ctx)
		for results.Next(ctx) {
			var singleBlock models.Block
			if err = results.Decode(&singleBlock); err != nil {
				writer.WriteHeader(http.StatusInternalServerError)
				response := responses.BlockResponse{
					Status:  http.StatusInternalServerError,
					Message: "Error al leer la base de datos",
					Data:    err.Error(),
				}
				_ = json.NewEncoder(writer).Encode(response)
			}
			blocks = append(blocks, singleBlock)
		}

		// Datos de la transacción
		previousBlock := blocks[len(blocks)-1]
		proofOfWork := functions.GetProofOfWork(previousBlock.Proof)
		hashPreviousBlock := functions.EncryptSHA256Block(previousBlock)

		// Crear firma del usuario registrado
		message := []byte("bloque firmado")
		messageHash := sha256.New()
		_, _ = messageHash.Write(message)
		messageHashSum := messageHash.Sum(nil)
		signature, _ := rsa.SignPKCS1v15(rand.Reader, privateKey, crypto.SHA256, messageHashSum)

		// Transferir 100.00 a la cuenta del usuario registrado
		newBlock := models.Block{
			Id:           primitive.NewObjectID(),
			Index:        len(blocks) + 1,
			PreviousHash: hashPreviousBlock,
			Proof:        proofOfWork,
			Timestamp:    time.Now().In(timeZone),
			Miner:        functions.EncryptSHA256String(functions.GetMacAddress()),
			Signature:    base64.StdEncoding.EncodeToString(signature),
			Transaction: models.Transaction{
				From:   functions.EncryptSHA256String(functions.GetMacAddress()),
				To:     user.Email,
				Amount: 100.00,
				Fee:    5.00,
			},
		}

		// Se inserta nuevo bloque en la base de datos
		_, err = blockCollection.InsertOne(ctx, newBlock)
		if err != nil {
			writer.WriteHeader(http.StatusInternalServerError)
			response := responses.BlockResponse{
				Status:  http.StatusInternalServerError,
				Message: "Error al insertar nuevo bloque en la cadena",
				Data:    err.Error(),
			}
			_ = json.NewEncoder(writer).Encode(response)
			return
		}

		// Se inserta nuevo bloque en la base de datos (réplica)
		//_, err = blockCollectionReplica.InsertOne(ctx, newBlock)
		if err != nil {
			// Se elimina el bloque insertado en la base de datos inicial
			_, _ = blockCollection.DeleteOne(ctx, bson.M{"_id": newBlock.Id})

			writer.WriteHeader(http.StatusInternalServerError)
			response := responses.BlockResponse{
				Status:  http.StatusInternalServerError,
				Message: "Error al insertar nuevo bloque en la cadena",
				Data:    err.Error(),
			}
			_ = json.NewEncoder(writer).Encode(response)
			return
		}

		var dbUser models.User
		_ = userCollection.FindOne(ctx, bson.M{"email": user.Email}).Decode(&dbUser)

		writer.WriteHeader(http.StatusCreated)
		response := responses.UserResponse{
			Status:  http.StatusCreated,
			Message: "Usuario registrado con éxito",
			Data:    dbUser,
		}
		_ = json.NewEncoder(writer).Encode(response)
		fmt.Printf("Código verificado, usuario %s registrado con éxito\n", user.Email)
	}
}

func GetAvailableUsers() http.HandlerFunc {
	return func(writer http.ResponseWriter, request *http.Request) {
		writer.Header().Set("Content-Type", "application/json; charset=utf-8")
		ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		params := mux.Vars(request)
		userEmail := params["userEmail"]
		var users []models.User
		defer cancel()

		results, err := userCollection.Find(ctx, bson.M{"email": bson.M{"$nin": bson.A{userEmail}}})

		if err != nil {
			writer.WriteHeader(http.StatusInternalServerError)
			response := responses.UserResponse{
				Status:  http.StatusInternalServerError,
				Message: "Error al obtener usuarios disponibles",
				Data:    err.Error(),
			}
			_ = json.NewEncoder(writer).Encode(response)
			return
		}

		defer func(results *mongo.Cursor, ctx context.Context) {
			_ = results.Close(ctx)
		}(results, ctx)

		for results.Next(ctx) {
			var singleUser models.User
			if err := results.Decode(&singleUser); err != nil {
				writer.WriteHeader(http.StatusInternalServerError)
				response := responses.UserResponse{
					Status:  http.StatusInternalServerError,
					Message: "Resultados no tienen la estructura usuario",
					Data:    err.Error(),
				}
				_ = json.NewEncoder(writer).Encode(response)
			}
			users = append(users, models.User{
				Id:         singleUser.Id,
				FirstName:  singleUser.FirstName,
				LastName:   singleUser.LastName,
				Country:    singleUser.Country,
				Email:      singleUser.Email,
				Password:   "",
				PublicKey:  singleUser.PublicKey,
				PrivateKey: "",
			})
		}

		writer.WriteHeader(http.StatusOK)
		response := responses.UserResponse{
			Status:  http.StatusOK,
			Message: "Usuarios obtenidos con éxito",
			Data:    users,
		}
		_ = json.NewEncoder(writer).Encode(response)
		fmt.Printf("Usuarios disponibles para el usuario %s obtenidos con éxito\n", userEmail)
	}
}

func GetBalance() http.HandlerFunc {
	return func(writer http.ResponseWriter, request *http.Request) {
		writer.Header().Set("Content-Type", "application/json; charset=utf-8")
		ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		params := mux.Vars(request)
		userEmail := params["userEmail"]
		defer cancel()

		results, err := blockCollection.Find(ctx, bson.M{})

		if err != nil {
			writer.WriteHeader(http.StatusInternalServerError)
			response := responses.BlockResponse{
				Status:  http.StatusInternalServerError,
				Message: "No se ha podido leer la cadena de bloques",
				Data:    err.Error(),
			}
			_ = json.NewEncoder(writer).Encode(response)
			return
		}

		// Lectura de resultados de bloques
		defer func(results *mongo.Cursor, ctx context.Context) {
			_ = results.Close(ctx)
		}(results, ctx)

		var balance float64 = 0.00
		for results.Next(ctx) {
			var singleBlock models.Block
			if err = results.Decode(&singleBlock); err != nil {
				writer.WriteHeader(http.StatusInternalServerError)
				response := responses.BlockResponse{
					Status:  http.StatusInternalServerError,
					Message: "Error al leer bloque",
					Data:    err.Error(),
				}
				_ = json.NewEncoder(writer).Encode(response)
			}
			if singleBlock.Transaction.From == userEmail {
				balance -= singleBlock.Transaction.Amount
			}
			if singleBlock.Transaction.To == userEmail {
				balance += singleBlock.Transaction.Amount
			}
		}

		writer.WriteHeader(http.StatusOK)
		response := responses.UserResponse{
			Status:  http.StatusOK,
			Message: "Balance obtenido con éxito",
			Data:    map[string]interface{}{"balance": balance},
		}
		_ = json.NewEncoder(writer).Encode(response)
		fmt.Printf("Balance del usuario %s obtenido con éxito\n", userEmail)
	}
}
