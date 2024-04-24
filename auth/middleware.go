package auth

import (
	"context"
	"fmt"
	"github.com/emp1re/g-play/graph/model"
	"github.com/golang-jwt/jwt/v5"
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
)

func MiddleWare() gin.HandlerFunc {
	return func(c *gin.Context) {

		//token, err := Parse(c)
		//if err != nil {
		//	c.JSON(401, gin.H{"error": "unauthorized"})
		//	return
		//}
		//
		//claims, ok := token.Claims.(jwt.MapClaims)
		//
		//if !ok || !token.Valid {
		//	c.JSON(401, gin.H{"error": "unauthorized"})
		//	return
		//}
		//
		//if claims["uid"] == nil {
		//	c.JSON(401, gin.H{"error": "unauthorized"})
		//	return
		//}
		ctx := context.WithValue(c, userCtxKey, &model.User{})

		c.Request = c.Request.WithContext(ctx)

		c.Next()

		//ctx := context.WithValue(r.Context(), userCtxKey, &user)
		//
		//// and call the next with our new context
		//r = r.WithContext(ctx)
		//.Next()
		//next.ServeHTTP(w, r)
	}
}

var userCtxKey = &contextKey{"user"}

type contextKey struct {
	name string
}

func ForContext(ctx context.Context) *model.User {
	raw, _ := ctx.Value(userCtxKey).(*model.User)
	return raw
}

func Parse(token string, secret string) (*jwt.Token, error) {
	decoded, err := jwt.Parse(token, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("Unexpected signing method: %v", token.Header["alg"])
		}
		return []byte(secret), nil
	})
	return decoded, err
}

func GetBearer(r *http.Request) string {
	var accessToken string
	authHeader := strings.SplitN(r.Header.Get("Authorization"), " ", 2)
	if len(authHeader) == 2 && strings.EqualFold("Bearer", authHeader[0]) {
		// has access token
		accessToken = authHeader[1]
	}
	return accessToken
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
