package main

import (
	"Crypto_Exchange_Backend/routes"
	"log"
	"net/http"

	"github.com/gorilla/mux"
	"github.com/rs/cors"
)

func main() {
	router := mux.NewRouter()

	// Rutas de Blockchain
	routes.BlockRoute(router)

	// Rutas de Users
	routes.UserRoute(router)

	// Habilitar CORS para todas las rutas
	corsRouter := cors.New(cors.Options{
		AllowedMethods: []string{"POST", "GET", "PUT", "DELETE"},
	}).Handler(router)

	log.Fatal(http.ListenAndServe(":8080", corsRouter))
}
