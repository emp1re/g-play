package database

import (
	"context"
	"sync"
	"time"

	"github.com/emp1re/g-play/config"
	pgxzap "github.com/jackc/pgx-zap"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/jackc/pgx/v5/tracelog"
	"go.uber.org/zap"
)

var (
	once  sync.Once
	types []*pgtype.Type
)

func GetDBPool(logger *zap.Logger) (*pgxpool.Pool, error) {

	poolConfig, err := pgxpool.ParseConfig(config.DATABASE_URL)
	if err != nil {
		return nil, err
	}

	level := tracelog.LogLevelTrace

	poolConfig.MinConns = 2
	poolConfig.MaxConns = int32(2)
	poolConfig.MaxConnLifetime = time.Hour
	poolConfig.MaxConnIdleTime = time.Minute * 10
	poolConfig.ConnConfig.Tracer = &tracelog.TraceLog{
		Logger:   pgxzap.NewLogger(logger),
		LogLevel: level,
	}
	poolConfig.AfterConnect = registerCustomTypes
	pool, err := pgxpool.NewWithConfig(context.Background(), poolConfig)

	return pool, err
}

func GetDatabase(l *zap.Logger) (*pgx.Conn, error) {
	dbconfig, err := pgx.ParseConfig(config.DATABASE_URL)
	if err != nil {
		return nil, err
	}

	dbconfig.Tracer = &tracelog.TraceLog{
		Logger:   pgxzap.NewLogger(l),
		LogLevel: tracelog.LogLevelTrace,
	}

	return pgx.ConnectConfig(context.TODO(), dbconfig)
}

func registerCustomTypes(ctx context.Context, conn *pgx.Conn) error {
	once.Do(func() {
		loadCustomTypes(conn)
	})

	for _, t := range types {
		conn.TypeMap().RegisterType(t)
	}

	return nil
}

func loadCustomTypes(conn *pgx.Conn) error {
	rows, err := conn.Query(context.Background(), "SELECT oid, typname FROM pg_type t WHERE t.typtype = 'e';")
	if err != nil {
		return err
	}
	defer rows.Close()

	types = []*pgtype.Type{}

	for rows.Next() {
		var oid uint32
		var name string
		err := rows.Scan(&oid, &name)
		if err != nil {
			return err
		}
		types = append(types, &pgtype.Type{Codec: &pgtype.EnumCodec{}, Name: name, OID: oid})
	}

	return nil
}
