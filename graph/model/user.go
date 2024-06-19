package model

import "context"

type userKey string

const contextKey userKey = "role"

type User struct {
	ID        int64      `json:"id"`
	FirstName string     `json:"firstName"`
	LastName  string     `json:"lastName"`
	Email     string     `json:"email"`
	Projects  []*Project `json:"Projects"`
	Role      []Role     `json:"role"`
}

func (u *User) AddRole(role Role) {
	u.Role = append(u.Role, role)
}

func (u *User) HasRole(role Role) bool {
	for _, r := range u.Role {
		if r == role {
			return true
		}
	}
	return false
}

func AddToContext(ctx context.Context, r *Role) context.Context {
	return context.WithValue(ctx, contextKey, r)
}

func FromContext(ctx context.Context) (*Role, bool) {
	r, ok := ctx.Value(contextKey).(*Role)
	return r, ok
}
