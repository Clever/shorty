package routes

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"strings"
	"time"

	database "github.com/Clever/shorty/db"
	"github.com/gorilla/mux"
	"gopkg.in/Clever/kayvee-go.v3/logger"
)

const (
	errMsgTemplate  = "<html>Unable to find long URL for slug: <em>'%s'</em>, please consult <a href='http://%s/'>http://%s</a> or the proper admin instance to add this slug.</html>"
	readOnlyMessage = "You have reached the read-only instance of this shortener. If you have access, please visit the admin instance to perform write operations."
)

var (
	reserved = []string{"delete", "shorten", "list", "meta", "Shortener.jsx", "favicon.png"}
	lg       = logger.New("shorty")
)

type httpError struct {
	Err  string
	Code int
}

func (h *httpError) Error() string {
	return h.Err
}

// returnJSON takes in the data, an error that just consists of a message and a code,
// and a response writer. If the error is not nil, we write the err code out and log
// that there was an error, otherwise we JSON encode the data and return
func returnJSON(data interface{}, inErr *httpError, w http.ResponseWriter) {
	if inErr != nil {
		lg.ErrorD("internal.error", logger.M{"msg": inErr.Error()})
		data = logger.M{"error": inErr.Error()}
		w.WriteHeader(inErr.Code)
		return
	}

	w.Header().Add("Content-Type", "application/json; charset=utf-8")
	err := json.NewEncoder(w).Encode(data)
	if err != nil {
		lg.ErrorD("json.encoding", logger.M{"msg": err.Error()})
	}

	return
}

// ReadOnlyHandler returns a message to the user saying that they need
// to find the write-domain to modify things. This shouldn't be hit too
// often as the admin interface itself will hide the user-facing input
func ReadOnlyHandler() func(http.ResponseWriter, *http.Request) {
	return func(w http.ResponseWriter, r *http.Request) {
		log.Println("In read-only mode, returning 401")
		returnJSON(nil, &httpError{readOnlyMessage, 401}, w)
		return
	}
}

// ShortenHandler generates a HTTP handler for a shortening URLs given a datastore backend.
func ShortenHandler(db database.ShortenBackend) func(http.ResponseWriter, *http.Request) {
	return func(w http.ResponseWriter, r *http.Request) {
		if err := r.ParseForm(); err != nil {
			returnJSON(nil, &httpError{fmt.Sprintf("couldn't parse form: %s", err.Error()), 500}, w)
			return
		}
		slug := r.PostForm.Get("slug")
		longURL := r.PostForm.Get("long_url")
		owner := r.PostForm.Get("owner")

		if strings.Contains(slug, "/") {
			returnJSON(nil, &httpError{fmt.Sprintf("You may not create a slug with a forward slash: %s", slug), 400}, w)
			return
		}

		for _, res := range reserved {
			if slug == res {
				returnJSON(nil, &httpError{fmt.Sprintf("That slug is reserved: %s", slug), 400}, w)
				return
			}
		}

		if len(slug) == 0 {
			returnJSON(nil, &httpError{"must provide a slug", 400}, w)
			return
		}

		if len(longURL) == 0 {
			returnJSON(nil, &httpError{"must provide a destination URL", 400}, w)
			return
		}

		// for now set expiry to never
		var t time.Time
		err := db.ShortenURL(slug, longURL, owner, t)
		var hErr *httpError = nil
		if err != nil {
			hErr = &httpError{err.Error(), 500}
		}
		returnJSON(nil, hErr, w)
		return
	}
}

// DeleteHandler generates a HTTP handler for deleting URL's given a datastore backend.
func DeleteHandler(db database.ShortenBackend) func(http.ResponseWriter, *http.Request) {
	return func(w http.ResponseWriter, r *http.Request) {
		if err := r.ParseForm(); err != nil {
			returnJSON(nil, &httpError{fmt.Sprintf("couldn't parse form: %s", err.Error()), 500}, w)
			return
		}
		slug := r.PostForm.Get("slug")
		var hErr *httpError = nil
		err := db.DeleteURL(slug)
		if err != nil {
			hErr = &httpError{err.Error(), 500}
		}
		returnJSON(nil, hErr, w)
	}
}

// MetaHandler returns info on the protocol and the domain for our short URLs
// Seems a little weird, but follows react patterns
func MetaHandler(protocol, domain string) func(http.ResponseWriter, *http.Request) {
	return func(w http.ResponseWriter, r *http.Request) {
		retObj := map[string]string{
			"protocol": protocol,
			"domain":   domain,
		}
		returnJSON(retObj, nil, w)
	}
}

// ListHandler generates a HTTP handler for listing URL's given a datastore backend.
func ListHandler(db database.ShortenBackend) func(http.ResponseWriter, *http.Request) {
	return func(w http.ResponseWriter, r *http.Request) {
		var hErr *httpError = nil
		sObj, err := db.GetList()
		if err != nil {
			hErr = &httpError{err.Error(), 500}
		}

		returnJSON(sObj, hErr, w)
	}
}

// RedirectHandler redirects users to their desired location.
// Not accessed via Ajax, just by end users
func RedirectHandler(db database.ShortenBackend, domain, slugSeparator string) func(http.ResponseWriter, *http.Request) {
	return func(w http.ResponseWriter, r *http.Request) {
		slug := mux.Vars(r)["slug"]
		suffix := mux.Vars(r)["suffix"]
		long, err := db.GetLongURL(slug)
		if err == database.ErrNotFound {
			w.WriteHeader(404)
			fmt.Fprint(w, fmt.Sprintf(errMsgTemplate, slug, domain, domain))
			return
		}
		if err != nil {
			lg.ErrorD("redirect.error", logger.M{"msg": err.Error()})
			w.WriteHeader(500)
			w.Write([]byte(err.Error()))
			return
		}
		http.Redirect(w, r, fmt.Sprintf("%s%s%s", long, slugSeparator, suffix), 302)
		return
	}
}
