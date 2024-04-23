package model

type Key struct {
	ID        int64    `json:"id"`
	Name      string   `json:"name"`
	ProjectID int64    `json:"projectID"`
	LocaleID  int64    `json:"localeID"`
	Locale    *Locale  `json:"locale"`
	Project   *Project `json:"project"`
}
