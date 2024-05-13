package routes

import (
	"Crypto_Exchange_Backend/controllers"

	"github.com/gorilla/mux"
)

func BlockRoute(router *mux.Router) {
	router.HandleFunc("/newTransaction", controllers.NewTransaction()).Methods("POST")
	router.HandleFunc("/getBlockchain", controllers.GetBlockchain()).Methods("GET")
	router.HandleFunc("/getMiners", controllers.GetMiners()).Methods("GET")
	router.HandleFunc("/validateBlockchain", controllers.ValidateBlockchain()).Methods("GET")
}
