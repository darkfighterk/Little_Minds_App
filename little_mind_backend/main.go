// main.go - FULL COMPLETE VERSION (Fixed CORS + Puzzles)
package main

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"time"

	firebase "firebase.google.com/go"
	"firebase.google.com/go/db"
	"github.com/golang-jwt/jwt/v5"
	"golang.org/x/crypto/bcrypt"
	"google.golang.org/api/option"
)

// ==========================
// Models
// ==========================
type User struct {
	Name     string `json:"name"`
	Email    string `json:"email"`
	Password string `json:"password,omitempty"`
}

// ==========================
// Globals
// ==========================
var jwtSecret = []byte("my_secret_key")
var firebaseClient *db.Client

const adminSecret = "LittleMind@Admin2024"

// ==========================
// Main
// ==========================
func main() {
	// Firebase Setup (New Project)
	opt := option.WithCredentialsFile("littelminds-e4497-firebase-adminsdk-fbsvc-b92afb8c92.json")

	config := &firebase.Config{
		DatabaseURL: "https://littelminds-e4497-default-rtdb.firebaseio.com/",
	}

	app, err := firebase.NewApp(context.Background(), config, opt)
	if err != nil {
		log.Fatalln("Error initializing Firebase app:", err)
	}

	firebaseClient, err = app.Database(context.Background())
	if err != nil {
		log.Fatalln("Error connecting to Firebase DB:", err)
	}

	log.Println("✅ Firebase Connected successfully to littelminds-e4497")

	// Create uploads folder
	if err := os.MkdirAll("./uploads", 0755); err != nil {
		log.Fatal("Cannot create uploads directory:", err)
	}

	// Setup routes
	mux := http.NewServeMux()

	mux.HandleFunc("/", rootHandler)
	mux.HandleFunc("/register", registerHandler)
	mux.HandleFunc("/login", loginHandler)
	mux.HandleFunc("/puzzles", puzzlesHandler) // Important for your current error
	mux.Handle("/uploads/", http.StripPrefix("/uploads/", http.FileServer(http.Dir("./uploads"))))
	mux.HandleFunc("/admin/upload", adminUploadHandler)

	// Apply CORS to all routes
	handler := enableCORS(mux)

	log.Println("🚀 Server started at http://localhost:8080")
	log.Fatal(http.ListenAndServe(":8080", handler))
}

// ==========================
// CORS Middleware
// ==========================
func enableCORS(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Authorization, X-Admin-Key")

		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}
		next.ServeHTTP(w, r)
	})
}

// ==========================
// Handlers
// ==========================
func rootHandler(w http.ResponseWriter, r *http.Request) {
	writeJSON(w, "Little Mind API v3.0.0", "", nil)
}

// Register Handler
func registerHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		writeJSONError(w, "Method not allowed")
		return
	}

	var user User
	if err := json.NewDecoder(r.Body).Decode(&user); err != nil {
		writeJSONError(w, "Invalid request body")
		return
	}

	if user.Email == "" || user.Password == "" {
		writeJSONError(w, "Email and password are required")
		return
	}

	safeKey := sanitizeKey(user.Email)
	ref := firebaseClient.NewRef("users/" + safeKey)

	var existing map[string]interface{}
	_ = ref.Get(context.Background(), &existing)
	if existing != nil && len(existing) > 0 {
		writeJSON(w, "", "Email already registered", nil)
		return
	}

	hashed, err := bcrypt.GenerateFromPassword([]byte(user.Password), bcrypt.DefaultCost)
	if err != nil {
		writeJSONError(w, "Password hashing failed")
		return
	}

	userToSave := User{
		Name:     user.Name,
		Email:    user.Email,
		Password: string(hashed),
	}

	if err := ref.Set(context.Background(), userToSave); err != nil {
		log.Printf("❌ Firebase write failed: %v", err)
		writeJSONError(w, "Registration failed")
		return
	}

	log.Printf("✅ User registered successfully: %s", user.Email)

	writeJSON(w, "User created successfully", "", map[string]interface{}{
		"id":    user.Email,
		"email": user.Email,
		"name":  user.Name,
	})
}

// Login Handler
func loginHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		writeJSONError(w, "Method not allowed")
		return
	}

	var req User
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeJSONError(w, "Invalid request")
		return
	}

	ref := firebaseClient.NewRef("users/" + sanitizeKey(req.Email))

	var dbUser User
	if err := ref.Get(context.Background(), &dbUser); err != nil || dbUser.Email == "" {
		writeJSON(w, "", "Invalid credentials", nil)
		return
	}

	if bcrypt.CompareHashAndPassword([]byte(dbUser.Password), []byte(req.Password)) != nil {
		writeJSON(w, "", "Invalid credentials", nil)
		return
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"email": dbUser.Email,
		"exp":   time.Now().Add(24 * time.Hour).Unix(),
	})

	tokenStr, _ := token.SignedString(jwtSecret)

	writeJSON(w, "Login successful", "", map[string]interface{}{
		"id":    dbUser.Email,
		"email": dbUser.Email,
		"token": tokenStr,
	})
}

// Puzzles Handler - Fixed to return proper structure
func puzzlesHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		writeJSONError(w, "Method not allowed")
		return
	}

	// Sample puzzles - Replace this later with real data from Firebase
	puzzles := []map[string]interface{}{
		{
			"id":          "1",
			"title":       "Basic Addition",
			"category":    "math",
			"difficulty":  "easy",
			"description": "What is 15 + 27?",
			"answer":      "42",
		},
		{
			"id":          "2",
			"title":       "World Capital",
			"category":    "general",
			"difficulty":  "medium",
			"description": "Capital of Japan?",
			"answer":      "Tokyo",
		},
		{
			"id":          "3",
			"title":       "Logic Riddle",
			"category":    "logic",
			"difficulty":  "hard",
			"description": "What has keys but can't open locks?",
			"answer":      "Piano",
		},
	}

	writeJSON(w, "Puzzles fetched successfully", "", map[string]interface{}{
		"puzzles": puzzles,
	})
}

// Admin Upload Handler
func adminUploadHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		writeJSONError(w, "Method not allowed")
		return
	}

	file, header, err := r.FormFile("image")
	if err != nil {
		writeJSONError(w, "No file uploaded")
		return
	}
	defer file.Close()

	ext := strings.ToLower(filepath.Ext(header.Filename))
	filename := fmt.Sprintf("%d%s", time.Now().UnixNano(), ext)

	dst, _ := os.Create("./uploads/" + filename)
	defer dst.Close()
	io.Copy(dst, file)

	host := r.Host
	if host == "" {
		host = "localhost:8080"
	}

	writeJSON(w, "File uploaded successfully", "", map[string]string{
		"url": fmt.Sprintf("http://%s/uploads/%s", host, filename),
	})
}

// ==========================
// Utilities
// ==========================
func sanitizeKey(s string) string {
	return strings.ReplaceAll(strings.ReplaceAll(s, ".", "_"), "@", "_")
}

func writeJSONError(w http.ResponseWriter, errMsg string) {
	writeJSON(w, "", errMsg, nil)
}

func writeJSON(w http.ResponseWriter, message, errMsg string, data interface{}) {
	w.Header().Set("Content-Type", "application/json")
	resp := map[string]interface{}{
		"message": message,
		"error":   errMsg,
	}
	if data != nil {
		resp["data"] = data
	}
	json.NewEncoder(w).Encode(resp)
}
