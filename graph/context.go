package graph

import (
	"context"

	"github.com/emp1re/g-play/database"
	"github.com/emp1re/g-play/database/models"
	"go.uber.org/zap"
)

type Context struct {
	L *zap.Logger
	R *Resolver
	D database.Pool
	Q *models.Queries
	C context.Context
}
