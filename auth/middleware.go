package auth

import (
	"os"
	"strings"

	"github.com/dgrijalva/jwt-go"
	"github.com/dgrijalva/jwt-go/request"
	"github.com/gin-gonic/gin"
	"github.com/pkg/errors"
)

func MiddleWare() gin.HandlerFunc {
	return func(c *gin.Context) {

		token, err := parseToken(c)
		if err != nil {
			c.JSON(401, gin.H{"error": "unauthorized"})
			return
		}

		claims, ok := token.Claims.(jwt.MapClaims)

		if !ok || !token.Valid {
			c.JSON(401, gin.H{"error": "unauthorized"})
			return
		}

		if claims["uid"] == nil {
			c.JSON(401, gin.H{"error": "unauthorized"})
			return
		}
	}

}

var authHeaderExtractor = &request.PostExtractionFilter{
	Extractor: request.HeaderExtractor{"Authorization"},
	Filter:    stripBearerPrefixFromToken,
}

func stripBearerPrefixFromToken(token string) (string, error) {
	bearer := "BEARER"

	if len(token) > len(bearer) && strings.ToUpper(token[0:len(bearer)]) == bearer {
		return token[len(bearer)+1:], nil
	}

	return token, nil
}

var authExtractor = &request.MultiExtractor{
	authHeaderExtractor,
	request.ArgumentExtractor{"access_token"},
}

func parseToken(c *gin.Context) (*jwt.Token, error) {
	jwtToken, err := request.ParseFromRequest(c.Request, authExtractor, func(token *jwt.Token) (interface{}, error) {
		t := []byte(os.Getenv("JWT_SECRET"))
		return t, nil
	})

	return jwtToken, errors.Wrap(err, "parseToken error: ")
}

//func setCredentials(ctx context.Context) (*models.User, error) {
//	errNoUserInContext := errors.New("no user in context")
//
//	if ctx.Value(userKey) == nil {
//		return nil, errNoUserInContext
//	}
//
//	user, ok := ctx.Value(userKey).(*models.User)
//	if !ok || user.ID == "" {
//		return nil, errNoUserInContext
//	}
//
//	return user, nil
//}
