package models

import (
	"encoding/json"
	"errors"
)

type ValueWithPlurals struct {
	Value      string   `json:"value,omitempty"`
	Plurals    []string `json:"plurals"`
	HasPlurals bool     `json:"-"`
}

func NewValueFromString(value string) ValueWithPlurals {
	return ValueWithPlurals{Value: value}
}

func NewPluralsFromString(plurals []string) ValueWithPlurals {
	return ValueWithPlurals{Plurals: plurals, HasPlurals: true}
}

func (v *ValueWithPlurals) UnmarshalJSON(data []byte) error {
	if len(data) == 0 {
		*v = ValueWithPlurals{}
		return nil
	}

	if data[0] == '"' {
		*v = ValueWithPlurals{Value: string(data[1 : len(data)-1])}
		return nil
	}

	if data[0] == '[' {
		var plurals []string

		if err := json.Unmarshal(data, &plurals); err != nil {
			return err
		}

		*v = ValueWithPlurals{Plurals: plurals, HasPlurals: true}
		return nil
	}

	return errors.New("invalid json for ValueWithPlurals")
}

func (v ValueWithPlurals) MarshalJSON() ([]byte, error) {
	if v.HasPlurals {
		return json.Marshal(v.Plurals)
	}
	return json.Marshal(v.Value)
}
