package main

import (
	"database/sql"
	"encoding/json"
	"log"
	"net/http"
	"time"

	_ "github.com/go-sql-driver/mysql"
	"github.com/golang-jwt/jwt/v5" // JWT library for secure authentication
	"golang.org/x/crypto/bcrypt"   // Library for password hashing and verification
)

// =====================
// Data Models
// =====================

// User represents the user account structure in the database
type User struct {
	ID       int    `json:"id"`
	Name     string `json:"name"`
	Email    string `json:"email"`
	Password string `json:"password,omitempty"` // omitempty prevents password from being sent in JSON responses
}

// Course represents the educational content structure
type Course struct {
	ID          int    `json:"id"`
	Title       string `json:"title"`
	Category    string `json:"category"`
	Description string `json:"description"`
	ImageURL    string `json:"imageUrl"`
	Instructor  string `json:"instructor"`
}

// Response is a generic structure for all API responses
type Response struct {
	Message string      `json:"message"`
	Data    interface{} `json:"data,omitempty"`
	Error   string      `json:"error,omitempty"`
}

// =====================
// Global Variables & Security
// =====================

var jwtSecret = []byte("my_secret_key") // Secret key for JWT signing
var db *sql.DB                          // Global database connection pool

func main() {
	var err error
	// Initialize MySQL connection to 'shopdb'
	db, err = sql.Open("mysql", "root:@tcp(127.0.0.1:3306)/little_mind_db")
	if err != nil {
		log.Fatal("Failed to open database connection:", err)
	}
	defer db.Close()

	// Verify database connectivity
	err = db.Ping()
	if err != nil {
		log.Fatal("Cannot reach the database server:", err)
	}
	log.Println("Database connected successfully")

	// =====================
	// API Route Definitions
	// =====================
	http.HandleFunc("/", rootHandler)
	http.HandleFunc("/register", enableCORS(registerHandler))
	http.HandleFunc("/login", enableCORS(loginHandler))

	// Endpoint for retrieving course lists with optional filtering
	http.HandleFunc("/courses", enableCORS(coursesHandler))

	log.Println("Server started at http://localhost:8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}

// =====================
// Middleware
// =====================

// enableCORS handles Cross-Origin Resource Sharing for frontend connectivity
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
// API Handlers
// =====================

// rootHandler provides API metadata and available endpoints
func rootHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(Response{
		Message: "Little Mind API is running",
		Data: map[string]interface{}{
			"version": "1.0.0",
			"endpoints": []string{
				"POST /register - Register a new user",
				"POST /login - Authenticate user",
				"GET /courses - Fetch all courses",
				"GET /courses?category=X - Filter courses by category",
			},
		},
	})
}

// registerHandler processes new user creation with password hashing
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
		json.NewEncoder(w).Encode(Response{Error: "Invalid request body"})
		return
	}

	// Validate required fields
	if user.Name == "" || user.Email == "" || user.Password == "" {
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(Response{Error: "All fields are required"})
		return
	}

	// Check for existing email in database
	var exists bool
	err = db.QueryRow("SELECT EXISTS(SELECT 1 FROM users WHERE email = ?)", user.Email).Scan(&exists)
	if err != nil {
		log.Println("Database lookup error:", err)
		w.WriteHeader(http.StatusInternalServerError)
		json.NewEncoder(w).Encode(Response{Error: "Database error"})
		return
	}

	if exists {
		w.WriteHeader(http.StatusConflict)
		json.NewEncoder(w).Encode(Response{Error: "Email already registered"})
		return
	}

	// Hash password for secure storage
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(user.Password), bcrypt.DefaultCost)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		json.NewEncoder(w).Encode(Response{Error: "Security processing error"})
		return
	}

	// Save new user record
	result, err := db.Exec("INSERT INTO users (name, email, password) VALUES (?, ?, ?)", user.Name, user.Email, string(hashedPassword))
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		json.NewEncoder(w).Encode(Response{Error: "Registration failed"})
		return
	}

	userID, _ := result.LastInsertId()

	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(Response{
		Message: "User created successfully",
		Data:    map[string]interface{}{"id": userID, "name": user.Name, "email": user.Email},
	})
}

// loginHandler verifies credentials and issues a JWT token
func loginHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	if r.Method != http.MethodPost {
		w.WriteHeader(http.StatusMethodNotAllowed)
		json.NewEncoder(w).Encode(Response{Error: "Method not allowed"})
		return
	}

	var user User
	json.NewDecoder(r.Body).Decode(&user)

	var dbUser User
	err := db.QueryRow("SELECT id, name, email, password FROM users WHERE email = ?", user.Email).Scan(
		&dbUser.ID, &dbUser.Name, &dbUser.Email, &dbUser.Password,
	)
	if err != nil {
		w.WriteHeader(http.StatusUnauthorized)
		json.NewEncoder(w).Encode(Response{Error: "Invalid credentials"})
		return
	}

	// Compare provided password with stored hash
	err = bcrypt.CompareHashAndPassword([]byte(dbUser.Password), []byte(user.Password))
	if err != nil {
		w.WriteHeader(http.StatusUnauthorized)
		json.NewEncoder(w).Encode(Response{Error: "Invalid credentials"})
		return
	}

	// Generate a 24-hour expiration JWT token
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"user_id": dbUser.ID,
		"email":   dbUser.Email,
		"exp":     time.Now().Add(time.Hour * 24).Unix(),
	})

	tokenString, _ := token.SignedString(jwtSecret)

	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(Response{
		Message: "Login successful",
		Data: map[string]interface{}{
			"id": dbUser.ID, "name": dbUser.Name, "email": dbUser.Email, "token": tokenString,
		},
	})
}

// coursesHandler handles fetching course lists with optional category filtering
func coursesHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	if r.Method != http.MethodGet {
		w.WriteHeader(http.StatusMethodNotAllowed)
		json.NewEncoder(w).Encode(Response{Error: "Method not allowed"})
		return
	}

	// Parse category query parameter from URL
	category := r.URL.Query().Get("category")
	var rows *sql.Rows
	var err error

	if category != "" {
		rows, err = db.Query("SELECT id, title, category, description, imageUrl, instructor FROM courses WHERE category = ?", category)
	} else {
		rows, err = db.Query("SELECT id, title, category, description, imageUrl, instructor FROM courses")
	}

	if err != nil {
		log.Println("Database query failed:", err)
		w.WriteHeader(http.StatusInternalServerError)
		json.NewEncoder(w).Encode(Response{Error: "Database access error"})
		return
	}
	defer rows.Close()

	courses := []Course{}
	for rows.Next() {
		var c Course
		if err := rows.Scan(&c.ID, &c.Title, &c.Category, &c.Description, &c.ImageURL, &c.Instructor); err != nil {
			continue
		}
		courses = append(courses, c)
	}

	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(Response{
		Message: "Courses retrieved successfully",
		Data:    courses,
	})
}
