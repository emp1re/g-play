package main

import (
	"log"

	"github.com/emp1re/g-play/config"
	"go.uber.org/zap"
)

var L *zap.Logger

func GetLogger() *zap.Logger {
	var err error
	if config.DEPLOYMENT == config.DeploymentProduction {
		L, err = zap.NewProduction()
	} else {
		L, err = zap.NewDevelopment()
	}

	if err != nil {
		log.Fatalf("can't start logging err: %v\n", zap.Error(err))
	}

	return L
}
