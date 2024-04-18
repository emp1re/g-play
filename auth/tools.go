package auth

import (
	"os"
	"time"

	"github.com/dgrijalva/jwt-go"
	"github.com/emp1re/g-play/graph/model"
	"golang.org/x/crypto/bcrypt"
)

type Payload map[string]interface{}

func HashPassword(password string) (string, error) {
	bytePassword := []byte(password)
	passwordHash, err := bcrypt.GenerateFromPassword(bytePassword, bcrypt.DefaultCost)
	if err != nil {
		return "", err
	}

	return string(passwordHash), nil
}

func GenToken(uid int64, pids []int64) (*model.AuthToken, error) {
	expiredAt := time.Now().Add(time.Hour * 24 * 7) // a week

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"exp":  expiredAt.Unix(),
		"uid":  uid,
		"pids": pids,
		"iat":  time.Now().Unix(),
		"iss":  "g-play",
	})

	accessToken, err := token.SignedString([]byte(os.Getenv("JWT_SECRET")))
	if err != nil {
		return nil, err
	}

	return &model.AuthToken{
		AccessToken: accessToken,
		ExpiredAt:   expiredAt,
	}, nil
}

func ComparePassword(pass1, pass2 string) error {
	bytePassword := []byte(pass1)
	byteHashedPassword := []byte(pass2)
	return bcrypt.CompareHashAndPassword(byteHashedPassword, bytePassword)
}
