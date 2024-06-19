package main

import (
	"context"
	"fmt"

	"github.com/99designs/gqlgen/graphql"
	"github.com/99designs/gqlgen/graphql/handler"
	"github.com/emp1re/g-play/config"
	"github.com/emp1re/g-play/database"
	"github.com/emp1re/g-play/database/models"
	"github.com/emp1re/g-play/graph"
	"github.com/emp1re/g-play/graph/model"
	"github.com/gin-gonic/gin"
	"go.uber.org/zap"
)

const defaultPort = ":8070"

// Defining the Graphql handler
func graphqlProtectedHandler(ctx *graph.Context) gin.HandlerFunc {

	return func(c *gin.Context) {
		cfg := graph.Config{Resolvers: &graph.Resolver{Tools: ctx}}
		cfg.Directives.HasRole = func(ctx context.Context, obj interface{}, next graphql.Resolver, role model.Role) (res interface{}, err error) {
			r := c.Request.Header.Get("Role")
			if r == "" {
				return nil, fmt.Errorf("role not provided in context")
			}
			if model.Role(r) != role {
				return nil, fmt.Errorf("access denied, %q role required", role)
			}

			ctx = model.AddToContext(ctx, (*model.Role)(&r))
			return next(ctx)
		}
		h := handler.NewDefaultServer(graph.NewExecutableSchema(cfg))

		h.ServeHTTP(c.Writer, c.Request)
	}
}

//func getCurrentUser(ctx context.Context) *model.User {
//	raw, _ := ctx.Value(contextKey).(*model.User)
//	return raw
//
//}

func main() {
	config.Read()
	l := GetLogger()
	defer l.Sync()
	d, err := database.GetDBPool(l)
	if err != nil {
		l.Fatal("cant' connect to database", zap.Error(err))
	}
	ctx := &graph.Context{
		L: l,
		D: d,
		Q: models.New(d),
	}

	// Setting up Gin
	r := gin.Default()

	r.GET("/", PlaygroundHandler())
	//r.Use(auth.MiddleWare())
	r.POST("/query", graphqlProtectedHandler(ctx))

	err = r.Run(defaultPort)
	if err != nil {

		l.Error("Error starting server", zap.Error(err))
		return
	}

}
