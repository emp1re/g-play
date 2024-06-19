package directives

import (
	"context"
)

type HasRoleDirective struct {
	Role string
}

func (h *HasRoleDirective) ImplementsDirective() string {
	return "hasRole"
}

func (h *HasRoleDirective) Validate(ctx context.Context, _ interface{}) error {

	return nil
}
