package main

import (
	"database/sql"
	"encoding/json"
	"log"
	"net/http"
	"time"

	_ "github.com/go-sql-driver/mysql"
	"github.com/golang-jwt/jwt/v5" // JWT library
	"golang.org/x/crypto/bcrypt"   // Password hashing
)

// =====================
// Models
// =====================
type User struct {
	ID       int    `json:"id"`
	Name     string `json:"name"`
	Email    string `json:"email"`
	Password string `json:"password,omitempty"`
}

type Response struct {
	Message string      `json:"message"`
	Data    interface{} `json:"data,omitempty"`
	Error   string      `json:"error,omitempty"`
}

// =====================
// JWT Secret Key (Keep it safe in env variables in production)
// =====================
var jwtSecret = []byte("my_secret_key")

// =====================
// Database
// =====================
var db *sql.DB

func main() {
	var err error
	db, err = sql.Open("mysql", "root:@tcp(127.0.0.1:3306)/shopdb")
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	// Test database connection
	err = db.Ping()
	if err != nil {
		log.Fatal("Cannot connect to database:", err)
	}
	log.Println("Database connected successfully")

	// =====================
	// Routes
	// =====================
	http.HandleFunc("/", rootHandler)
	http.HandleFunc("/register", enableCORS(registerHandler))
	http.HandleFunc("/login", enableCORS(loginHandler))

	log.Println("Server started at http://localhost:8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}

// =====================
// CORS Middleware
// =====================
func enableCORS(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "POST, GET, OPTIONS, PUT, DELETE")
		w.Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Authorization")

		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}

		next(w, r)
	}
}

// =====================
// Root Endpoint
// =====================
func rootHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(Response{
		Message: "Little Mind API is running",
		Data: map[string]interface{}{
			"version": "1.0.0",
			"endpoints": []string{
				"POST /register - Register a new user",
				"POST /login - Login user",
			},
		},
	})
}

// =====================
// Register Endpoint
// =====================
func registerHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	if r.Method != http.MethodPost {
		w.WriteHeader(http.StatusMethodNotAllowed)
		json.NewEncoder(w).Encode(Response{Error: "Method not allowed"})
		return
	}

	var user User
	err := json.NewDecoder(r.Body).Decode(&user)
	if err != nil {
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(Response{Error: "Invalid request payload"})
		return
	}

	if user.Name == "" || user.Email == "" || user.Password == "" {
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(Response{Error: "Name, email, and password are required"})
		return
	}

	// Check if user already exists
	var exists bool
	err = db.QueryRow("SELECT EXISTS(SELECT 1 FROM users WHERE email = ?)", user.Email).Scan(&exists)
	if err != nil {
		log.Println("Database error:", err)
		w.WriteHeader(http.StatusInternalServerError)
		json.NewEncoder(w).Encode(Response{Error: "Database error"})
		return
	}

	if exists {
		w.WriteHeader(http.StatusConflict)
		json.NewEncoder(w).Encode(Response{Error: "User with this email already exists"})
		return
	}

	// =====================
	// Hash the password before storing
	// =====================
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(user.Password), bcrypt.DefaultCost)
	if err != nil {
		log.Println("Error hashing password:", err)
		w.WriteHeader(http.StatusInternalServerError)
		json.NewEncoder(w).Encode(Response{Error: "Failed to process password"})
		return
	}

	// Insert user into database
	result, err := db.Exec("INSERT INTO users (name, email, password) VALUES (?, ?, ?)", user.Name, user.Email, string(hashedPassword))
	if err != nil {
		log.Println("Database error:", err)
		w.WriteHeader(http.StatusInternalServerError)
		json.NewEncoder(w).Encode(Response{Error: "Failed to register user"})
		return
	}

	userID, err := result.LastInsertId()
	if err != nil {
		log.Println("Error getting last insert ID:", err)
	}

	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(Response{
		Message: "User registered successfully",
		Data: map[string]interface{}{
			"id":    userID,
			"name":  user.Name,
			"email": user.Email,
		},
	})
}

// =====================
// Login Endpoint
// =====================
func loginHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	if r.Method != http.MethodPost {
		w.WriteHeader(http.StatusMethodNotAllowed)
		json.NewEncoder(w).Encode(Response{Error: "Method not allowed"})
		return
	}

	var user User
	err := json.NewDecoder(r.Body).Decode(&user)
	if err != nil {
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(Response{Error: "Invalid request payload"})
		return
	}

	if user.Email == "" || user.Password == "" {
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(Response{Error: "Email and password are required"})
		return
	}

	var dbUser User
	err = db.QueryRow("SELECT id, name, email, password FROM users WHERE email = ?", user.Email).Scan(
		&dbUser.ID, &dbUser.Name, &dbUser.Email, &dbUser.Password,
	)
	if err != nil {
		if err == sql.ErrNoRows {
			w.WriteHeader(http.StatusUnauthorized)
			json.NewEncoder(w).Encode(Response{Error: "Invalid email or password"})
			return
		}
		log.Println("Database error:", err)
		w.WriteHeader(http.StatusInternalServerError)
		json.NewEncoder(w).Encode(Response{Error: "Database error"})
		return
	}

	// =====================
	// Compare hashed passwords
	// =====================
	err = bcrypt.CompareHashAndPassword([]byte(dbUser.Password), []byte(user.Password))
	if err != nil {
		w.WriteHeader(http.StatusUnauthorized)
		json.NewEncoder(w).Encode(Response{Error: "Invalid email or password"})
		return
	}

	// =====================
	// Generate JWT token
	// =====================
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"user_id": dbUser.ID,
		"email":   dbUser.Email,
		"exp":     time.Now().Add(time.Hour * 24).Unix(), // token expires in 24h
	})

	tokenString, err := token.SignedString(jwtSecret)
	if err != nil {
		log.Println("Error generating JWT:", err)
		w.WriteHeader(http.StatusInternalServerError)
		json.NewEncoder(w).Encode(Response{Error: "Failed to generate token"})
		return
	}

	// Return user info + token
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(Response{
		Message: "Login successful",
		Data: map[string]interface{}{
			"id":    dbUser.ID,
			"name":  dbUser.Name,
			"email": dbUser.Email,
			"token": tokenString,
		},
	})
}
