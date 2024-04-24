package config

import (
	"log"
	"os"

	"github.com/joho/godotenv"
)

var (
	DATABASE_URL string
	JWT_SECRET   string
	DEPLOYMENT   DeploymentType
)

func Read() {
	err := godotenv.Load()
	if err != nil {
		log.Fatal("Error loading .env file")
	}
	DATABASE_URL = os.Getenv("DATABASE_URL")
	JWT_SECRET = os.Getenv("JWT_SECRET")
	DEPLOYMENT = getDeployment(os.Getenv("DEPLOYMENT"))

	// only for non-produciton deployments
	if DEPLOYMENT == DeploymentProduction {
		return
	}
}

func getDeployment(input string) DeploymentType {
	return DeploymentStaging
}

type DeploymentType string

const (
	DeploymentProduction DeploymentType = "production"
	DeploymentStaging    DeploymentType = "staging"
	DeploymentTest       DeploymentType = "test"
	DeploymentLocalhost  DeploymentType = "localhost"
)
