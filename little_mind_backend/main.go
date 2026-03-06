package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"time"

	_ "github.com/go-sql-driver/mysql"
	"github.com/golang-jwt/jwt/v5"
	"github.com/joho/godotenv"
	"golang.org/x/crypto/bcrypt"
)

// =====================================================================
// Data Models — Auth / Courses / Progress
// =====================================================================

type User struct {
	ID       int    `json:"id"`
	Name     string `json:"name"`
	Email    string `json:"email"`
	Password string `json:"password,omitempty"`
}

type Course struct {
	ID          int    `json:"id"`
	Title       string `json:"title"`
	Category    string `json:"category"`
	Description string `json:"description"`
	ImageURL    string `json:"imageUrl"`
	Instructor  string `json:"instructor"`
}

type SubjectProgress struct {
	SubjectID       string `json:"subject_id"`
	TotalStars      int    `json:"total_stars"`
	CompletedLevels []int  `json:"completed_levels"`
}

type LevelResult struct {
	UserID         int    `json:"user_id"`
	SubjectID      string `json:"subject_id"`
	LevelNumber    int    `json:"level_number"`
	StarsEarned    int    `json:"stars_earned"`
	QuizScore      int    `json:"quiz_score"`
	TotalQuestions int    `json:"total_questions"`
}

type Response struct {
	Message string      `json:"message"`
	Data    interface{} `json:"data,omitempty"`
	Error   string      `json:"error,omitempty"`
}

// =====================================================================
// Data Models — AI Chat
// =====================================================================

type ChatRequest struct {
	Message string `json:"message"`
}

type GroqMessage struct {
	Role    string `json:"role"`
	Content string `json:"content"`
}

type GroqRequest struct {
	Model    string        `json:"model"`
	Messages []GroqMessage `json:"messages"`
}

type GroqResponse struct {
	Choices []struct {
		Message struct {
			Content string `json:"content"`
		} `json:"message"`
	} `json:"choices"`
}

// =====================================================================
// Data Models — Admin Quiz (subjects / levels / questions)
// =====================================================================

type AdminSubject struct {
	ID            string `json:"id"`
	Name          string `json:"name"`
	Emoji         string `json:"emoji"`
	GradientStart string `json:"gradient_start"`
	GradientEnd   string `json:"gradient_end"`
}

type AdminLevel struct {
	ID            int    `json:"id"`
	SubjectID     string `json:"subject_id"`
	LevelNumber   int    `json:"level_number"`
	Title         string `json:"title"`
	Icon          string `json:"icon"`
	StarsRequired int    `json:"stars_required"`
}

type AdminQuestion struct {
	ID           int    `json:"id"`
	LevelID      int    `json:"level_id"`
	QuestionText string `json:"question_text"`
	ImageURL     string `json:"image_url"`
	OptionA      string `json:"option_a"`
	OptionB      string `json:"option_b"`
	OptionC      string `json:"option_c"`
	OptionD      string `json:"option_d"`
	CorrectIndex int    `json:"correct_index"`
	FunFact      string `json:"fun_fact"`
	SortOrder    int    `json:"sort_order"`
}

type BatchQuestionsRequest struct {
	LevelID   int             `json:"level_id"`
	Questions []AdminQuestion `json:"questions"`
}

type FullQuizSubject struct {
	AdminSubject
	Levels []FullQuizLevel `json:"levels"`
}

type FullQuizLevel struct {
	AdminLevel
	Questions []AdminQuestion `json:"questions"`
}

// =====================================================================
// Data Models — Jigsaw Puzzles
// =====================================================================

type JigsawPuzzle struct {
	ID         int    `json:"id"`
	Title      string `json:"title"`
	ImageURL   string `json:"image_url"`
	PieceCount int    `json:"piece_count"`
	Category   string `json:"category"`
	Difficulty string `json:"difficulty"`
	CreatedAt  string `json:"created_at,omitempty"`
}

// =====================================================================
// Data Models — Crossword Puzzles  (table: crossword_puzzles)
// =====================================================================

type CrosswordCell struct {
	IsBlack  bool   `json:"isBlack"`
	Number   *int   `json:"number,omitempty"`
	Solution string `json:"solution"`
}

type CrosswordClue struct {
	Number int    `json:"number"`
	Text   string `json:"text"`
}

type CrosswordPuzzle struct {
	ID           int               `json:"id"`
	Title        string            `json:"title"`
	Category     string            `json:"category"`
	Difficulty   string            `json:"difficulty"`
	Rows         int               `json:"rows"`
	Cols         int               `json:"cols"`
	GridData     [][]CrosswordCell `json:"gridData"`
	AcrossClues  []CrosswordClue   `json:"acrossClues"`
	DownClues    []CrosswordClue   `json:"downClues"`
	TimerMinutes int               `json:"timerMinutes"`
	CreatedAt    string            `json:"created_at,omitempty"`
}

// =====================================================================
// Data Models — Stories
// =====================================================================

type Story struct {
	ID          int         `json:"id"`
	Title       string      `json:"title"`
	Author      string      `json:"author"`
	Description string      `json:"description"`
	CoverURL    string      `json:"cover_url"`
	CoverEmoji  string      `json:"cover_emoji"`
	Category    string      `json:"category"`
	Difficulty  string      `json:"difficulty"`
	AgeRange    string      `json:"age_range"`
	PageCount   int         `json:"page_count,omitempty"`
	CreatedAt   string      `json:"created_at,omitempty"`
	Pages       []StoryPage `json:"pages,omitempty"`
}

type StoryPage struct {
	ID         int    `json:"id"`
	StoryID    int    `json:"story_id"`
	PageNumber int    `json:"page_number"`
	Title      string `json:"title"`
	Body       string `json:"body"`
	ImageURL   string `json:"image_url"`
}

// =====================================================================
// Globals
// =====================================================================

var jwtSecret = []byte("my_secret_key")
var db *sql.DB

const adminSecret = "LittleMind@Admin2024"

// =====================================================================
// main
// =====================================================================

func main() {
	envErr := godotenv.Load()
	if envErr != nil {
		log.Println("Warning: .env file not found, checking system environment variables...")
	}

	var err error
	db, err = sql.Open("mysql", "root:@tcp(127.0.0.1:3306)/little_mind_db?parseTime=true")
	if err != nil {
		log.Fatal("Failed to open database connection:", err)
	}
	defer db.Close()

	if err = db.Ping(); err != nil {
		log.Fatal("Cannot reach the database server:", err)
	}
	log.Println("✅ Database connected successfully (little_mind_db)")

	// ── Auto-migrate: ensure crossword_puzzles table + all columns exist ─
	_, err = db.Exec(`
		CREATE TABLE IF NOT EXISTS crossword_puzzles (
			id            INT          NOT NULL AUTO_INCREMENT PRIMARY KEY,
			title         VARCHAR(255) NOT NULL,
			created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
		) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
	`)
	if err != nil {
		log.Fatal("Failed to create crossword_puzzles table:", err)
	}
	// Add each column only if it doesn't already exist (safe to run every boot)
	crosswordAlters := []string{
		`ALTER TABLE crossword_puzzles ADD COLUMN IF NOT EXISTS category      VARCHAR(100) NOT NULL DEFAULT 'General'`,
		`ALTER TABLE crossword_puzzles ADD COLUMN IF NOT EXISTS difficulty    VARCHAR(50)  NOT NULL DEFAULT 'Medium'`,
		`ALTER TABLE crossword_puzzles ADD COLUMN IF NOT EXISTS grid_rows     INT          NOT NULL DEFAULT 10`,
		`ALTER TABLE crossword_puzzles ADD COLUMN IF NOT EXISTS grid_cols     INT          NOT NULL DEFAULT 10`,
		`ALTER TABLE crossword_puzzles ADD COLUMN IF NOT EXISTS grid_data     LONGTEXT`,
		`ALTER TABLE crossword_puzzles ADD COLUMN IF NOT EXISTS across_clues  TEXT`,
		`ALTER TABLE crossword_puzzles ADD COLUMN IF NOT EXISTS down_clues    TEXT`,
		`ALTER TABLE crossword_puzzles ADD COLUMN IF NOT EXISTS timer_minutes INT          NOT NULL DEFAULT 10`,
	}
	for _, alter := range crosswordAlters {
		if _, alterErr := db.Exec(alter); alterErr != nil {
			log.Printf("Warning: crossword alter skipped: %v", alterErr)
		}
	}
	log.Println("✅ crossword_puzzles table ready")

	if err := os.MkdirAll("./uploads", 0755); err != nil {
		log.Fatal("Cannot create uploads directory:", err)
	}

	// ── Static files ─────────────────────────────────────────────────
	http.Handle("/uploads/", enableCORSHandler(http.StripPrefix("/uploads/", http.FileServer(http.Dir("./uploads")))))

	// ── Auth & core ──────────────────────────────────────────────────
	http.HandleFunc("/", rootHandler)
	http.HandleFunc("/register", enableCORS(registerHandler))
	http.HandleFunc("/login", enableCORS(loginHandler))
	http.HandleFunc("/courses", enableCORS(coursesHandler))
	http.HandleFunc("/progress", enableCORS(requireAuth(progressHandler)))
	http.HandleFunc("/chat", enableCORS(aiChatHandler))

	// ── Admin — upload / subjects / levels / questions / quiz ────────
	http.HandleFunc("/admin/upload", enableCORS(requireAdmin(adminUploadHandler)))
	http.HandleFunc("/admin/subjects", enableCORS(requireAdmin(adminSubjectsHandler)))
	http.HandleFunc("/admin/levels", enableCORS(requireAdmin(adminLevelsHandler)))
	http.HandleFunc("/admin/questions", enableCORS(requireAdmin(adminQuestionsHandler)))
	http.HandleFunc("/admin/quiz", enableCORS(requireAdmin(adminFullQuizHandler)))

	// ── Jigsaw Puzzles ───────────────────────────────────────────────
	http.HandleFunc("/admin/puzzles", enableCORS(requireAdmin(adminJigsawPuzzlesHandler)))
	http.HandleFunc("/puzzles", enableCORS(jigsawPuzzlesPublicHandler))

	// ── Crossword Puzzles ────────────────────────────────────────────
	http.HandleFunc("/admin/crosswords", enableCORS(requireAdmin(adminCrosswordsHandler)))
	http.HandleFunc("/admin/crosswords/", enableCORS(requireAdmin(adminCrosswordDetailHandler)))
	http.HandleFunc("/crosswords", enableCORS(crosswordsPublicHandler))
	http.HandleFunc("/crosswords/", enableCORS(crosswordPublicDetailHandler))

	// ── Stories ──────────────────────────────────────────────────────
	http.HandleFunc("/admin/stories", enableCORS(requireAdmin(adminStoriesHandler)))
	http.HandleFunc("/admin/stories/", enableCORS(requireAdmin(adminStoryDetailHandler)))
	http.HandleFunc("/stories", enableCORS(storiesPublicHandler))
	http.HandleFunc("/stories/", enableCORS(storyPublicDetailHandler))

	log.Println("🚀 Server started at http://localhost:8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}

// =====================================================================
// Middleware
// =====================================================================

func enableCORS(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "POST, GET, OPTIONS, PUT, DELETE")
		w.Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Authorization, X-Admin-Key")
		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}
		next(w, r)
	}
}

func enableCORSHandler(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}
		next.ServeHTTP(w, r)
	})
}

func requireAuth(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		authHeader := r.Header.Get("Authorization")
		if authHeader == "" || !strings.HasPrefix(authHeader, "Bearer ") {
			w.WriteHeader(http.StatusUnauthorized)
			json.NewEncoder(w).Encode(Response{Error: "Missing or invalid authorization header"})
			return
		}
		tokenStr := strings.TrimPrefix(authHeader, "Bearer ")
		token, err := jwt.Parse(tokenStr, func(t *jwt.Token) (interface{}, error) {
			if _, ok := t.Method.(*jwt.SigningMethodHMAC); !ok {
				return nil, jwt.ErrSignatureInvalid
			}
			return jwtSecret, nil
		})
		if err != nil || !token.Valid {
			w.WriteHeader(http.StatusUnauthorized)
			json.NewEncoder(w).Encode(Response{Error: "Invalid or expired token"})
			return
		}
		next(w, r)
	}
}

func requireAdmin(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		key := r.Header.Get("X-Admin-Key")
		if key != adminSecret {
			w.WriteHeader(http.StatusForbidden)
			json.NewEncoder(w).Encode(Response{Error: "Admin access denied"})
			return
		}
		next(w, r)
	}
}

// =====================================================================
// Root
// =====================================================================

func rootHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(Response{
		Message: "Little Mind API v3.0.0",
		Data: map[string]interface{}{
			"version":  "3.0.0",
			"database": "little_mind_db",
		},
	})
}

// =====================================================================
// Auth
// =====================================================================

func registerHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	if r.Method != http.MethodPost {
		w.WriteHeader(http.StatusMethodNotAllowed)
		json.NewEncoder(w).Encode(Response{Error: "Method not allowed"})
		return
	}
	var user User
	if err := json.NewDecoder(r.Body).Decode(&user); err != nil {
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(Response{Error: "Invalid request body"})
		return
	}
	if user.Name == "" || user.Email == "" || user.Password == "" {
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(Response{Error: "All fields are required"})
		return
	}
	var exists bool
	if err := db.QueryRow("SELECT EXISTS(SELECT 1 FROM users WHERE email = ?)", user.Email).Scan(&exists); err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		json.NewEncoder(w).Encode(Response{Error: "Database error"})
		return
	}
	if exists {
		w.WriteHeader(http.StatusConflict)
		json.NewEncoder(w).Encode(Response{Error: "Email already registered"})
		return
	}
	hashed, err := bcrypt.GenerateFromPassword([]byte(user.Password), bcrypt.DefaultCost)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		json.NewEncoder(w).Encode(Response{Error: "Security processing error"})
		return
	}
	result, err := db.Exec("INSERT INTO users (name, email, password) VALUES (?, ?, ?)", user.Name, user.Email, string(hashed))
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
	err := db.QueryRow("SELECT id, name, email, password FROM users WHERE email = ?", user.Email).
		Scan(&dbUser.ID, &dbUser.Name, &dbUser.Email, &dbUser.Password)
	if err != nil {
		w.WriteHeader(http.StatusUnauthorized)
		json.NewEncoder(w).Encode(Response{Error: "Invalid credentials"})
		return
	}
	if err = bcrypt.CompareHashAndPassword([]byte(dbUser.Password), []byte(user.Password)); err != nil {
		w.WriteHeader(http.StatusUnauthorized)
		json.NewEncoder(w).Encode(Response{Error: "Invalid credentials"})
		return
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"user_id": dbUser.ID,
		"email":   dbUser.Email,
		"exp":     time.Now().Add(time.Hour * 24).Unix(),
	})
	tokenString, _ := token.SignedString(jwtSecret)
	json.NewEncoder(w).Encode(Response{
		Message: "Login successful",
		Data: map[string]interface{}{
			"id": dbUser.ID, "name": dbUser.Name,
			"email": dbUser.Email, "token": tokenString,
		},
	})
}

// =====================================================================
// Courses
// =====================================================================

func coursesHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	if r.Method != http.MethodGet {
		w.WriteHeader(http.StatusMethodNotAllowed)
		return
	}
	category := r.URL.Query().Get("category")
	var rows *sql.Rows
	var err error
	if category != "" {
		rows, err = db.Query("SELECT id, title, category, description, imageUrl, instructor FROM courses WHERE category = ?", category)
	} else {
		rows, err = db.Query("SELECT id, title, category, description, imageUrl, instructor FROM courses")
	}
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		json.NewEncoder(w).Encode(Response{Error: "Database access error"})
		return
	}
	defer rows.Close()
	courses := []Course{}
	for rows.Next() {
		var c Course
		rows.Scan(&c.ID, &c.Title, &c.Category, &c.Description, &c.ImageURL, &c.Instructor)
		courses = append(courses, c)
	}
	json.NewEncoder(w).Encode(Response{Message: "Courses retrieved successfully", Data: courses})
}

// =====================================================================
// Progress
// =====================================================================

func progressHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	switch r.Method {
	case http.MethodGet:
		getProgressHandler(w, r)
	case http.MethodPost:
		saveLevelResultHandler(w, r)
	default:
		w.WriteHeader(http.StatusMethodNotAllowed)
	}
}

func getProgressHandler(w http.ResponseWriter, r *http.Request) {
	userIDStr := r.URL.Query().Get("user_id")
	subjectID := r.URL.Query().Get("subject_id")
	if userIDStr == "" {
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(Response{Error: "user_id is required"})
		return
	}
	if subjectID != "" {
		progress, err := fetchSubjectProgress(userIDStr, subjectID)
		if err != nil {
			w.WriteHeader(http.StatusInternalServerError)
			json.NewEncoder(w).Encode(Response{Error: "Database error"})
			return
		}
		json.NewEncoder(w).Encode(Response{Message: "Progress retrieved", Data: progress})
		return
	}
	subjects := []string{"science", "biology", "history"}
	allProgress := make([]SubjectProgress, 0, len(subjects))
	for _, sid := range subjects {
		progress, err := fetchSubjectProgress(userIDStr, sid)
		if err != nil {
			continue
		}
		allProgress = append(allProgress, *progress)
	}
	json.NewEncoder(w).Encode(Response{Message: "All progress retrieved", Data: allProgress})
}

func fetchSubjectProgress(userID, subjectID string) (*SubjectProgress, error) {
	sp := &SubjectProgress{SubjectID: subjectID, TotalStars: 0, CompletedLevels: []int{}}
	err := db.QueryRow(
		"SELECT COALESCE(total_stars, 0) FROM user_subject_progress WHERE user_id = ? AND subject_id = ?",
		userID, subjectID,
	).Scan(&sp.TotalStars)
	if err != nil && err != sql.ErrNoRows {
		return nil, err
	}
	rows, err := db.Query(
		"SELECT level_number FROM user_level_completions WHERE user_id = ? AND subject_id = ? ORDER BY level_number",
		userID, subjectID,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	for rows.Next() {
		var lvl int
		if err := rows.Scan(&lvl); err == nil {
			sp.CompletedLevels = append(sp.CompletedLevels, lvl)
		}
	}
	return sp, nil
}

func saveLevelResultHandler(w http.ResponseWriter, r *http.Request) {
	var result LevelResult
	if err := json.NewDecoder(r.Body).Decode(&result); err != nil {
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(Response{Error: "Invalid request body"})
		return
	}
	if result.UserID == 0 || result.SubjectID == "" || result.LevelNumber == 0 {
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(Response{Error: "user_id, subject_id and level_number are required"})
		return
	}
	_, err := db.Exec(`
		INSERT INTO user_level_completions
		    (user_id, subject_id, level_number, stars_earned, quiz_score, total_questions)
		VALUES (?, ?, ?, ?, ?, ?)
		ON DUPLICATE KEY UPDATE
		    stars_earned    = GREATEST(stars_earned,    VALUES(stars_earned)),
		    quiz_score      = GREATEST(quiz_score,      VALUES(quiz_score)),
		    total_questions = VALUES(total_questions),
		    completed_at    = CURRENT_TIMESTAMP
	`, result.UserID, result.SubjectID, result.LevelNumber,
		result.StarsEarned, result.QuizScore, result.TotalQuestions)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		json.NewEncoder(w).Encode(Response{Error: "Failed to save level result"})
		return
	}
	var totalStars int
	db.QueryRow(`SELECT COALESCE(SUM(stars_earned), 0) FROM user_level_completions WHERE user_id = ? AND subject_id = ?`,
		result.UserID, result.SubjectID).Scan(&totalStars)
	db.Exec(`INSERT INTO user_subject_progress (user_id, subject_id, total_stars) VALUES (?, ?, ?)
		ON DUPLICATE KEY UPDATE total_stars = VALUES(total_stars), updated_at = CURRENT_TIMESTAMP`,
		result.UserID, result.SubjectID, totalStars)
	json.NewEncoder(w).Encode(Response{
		Message: "Progress saved successfully",
		Data: map[string]interface{}{
			"subject_id": result.SubjectID, "total_stars": totalStars,
			"stars_earned": result.StarsEarned, "level": result.LevelNumber,
		},
	})
}

// =====================================================================
// Admin — Image Upload
// =====================================================================

func adminUploadHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		w.WriteHeader(http.StatusMethodNotAllowed)
		return
	}
	if err := r.ParseMultipartForm(10 << 20); err != nil {
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(Response{Error: "Image too large (max 10 MB)"})
		return
	}
	file, header, err := r.FormFile("image")
	if err != nil {
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(Response{Error: "Field 'image' is missing"})
		return
	}
	defer file.Close()
	ext := strings.ToLower(filepath.Ext(header.Filename))
	allowed := map[string]bool{".jpg": true, ".jpeg": true, ".png": true, ".gif": true, ".webp": true}
	if !allowed[ext] {
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(Response{Error: "Only jpg, png, gif, webp allowed"})
		return
	}
	filename := fmt.Sprintf("%d%s", time.Now().UnixNano(), ext)
	dst, err := os.Create("./uploads/" + filename)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		json.NewEncoder(w).Encode(Response{Error: "Could not save image"})
		return
	}
	defer dst.Close()
	io.Copy(dst, file)
	host := r.Host
	if host == "" {
		host = "localhost:8080"
	}
	imageURL := fmt.Sprintf("http://%s/uploads/%s", host, filename)
	json.NewEncoder(w).Encode(Response{
		Message: "Image uploaded successfully",
		Data:    map[string]string{"url": imageURL},
	})
}

// =====================================================================
// Admin — Subjects
// =====================================================================

func adminSubjectsHandler(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case http.MethodGet:
		rows, err := db.Query("SELECT id, name, emoji, gradient_start, gradient_end FROM quiz_subjects ORDER BY id")
		if err != nil {
			w.WriteHeader(http.StatusInternalServerError)
			json.NewEncoder(w).Encode(Response{Error: "Database error"})
			return
		}
		defer rows.Close()
		subjects := []AdminSubject{}
		for rows.Next() {
			var s AdminSubject
			rows.Scan(&s.ID, &s.Name, &s.Emoji, &s.GradientStart, &s.GradientEnd)
			subjects = append(subjects, s)
		}
		json.NewEncoder(w).Encode(Response{Message: "Subjects retrieved", Data: subjects})

	case http.MethodPost:
		var s AdminSubject
		if err := json.NewDecoder(r.Body).Decode(&s); err != nil || s.ID == "" || s.Name == "" {
			w.WriteHeader(http.StatusBadRequest)
			json.NewEncoder(w).Encode(Response{Error: "id and name are required"})
			return
		}
		if s.Emoji == "" {
			s.Emoji = "📚"
		}
		if s.GradientStart == "" {
			s.GradientStart = "#4FC3F7"
		}
		if s.GradientEnd == "" {
			s.GradientEnd = "#0288D1"
		}
		_, err := db.Exec("INSERT INTO quiz_subjects (id, name, emoji, gradient_start, gradient_end) VALUES (?, ?, ?, ?, ?)",
			s.ID, s.Name, s.Emoji, s.GradientStart, s.GradientEnd)
		if err != nil {
			w.WriteHeader(http.StatusInternalServerError)
			json.NewEncoder(w).Encode(Response{Error: "Failed to create subject"})
			return
		}
		w.WriteHeader(http.StatusCreated)
		json.NewEncoder(w).Encode(Response{Message: "Subject created", Data: s})

	default:
		w.WriteHeader(http.StatusMethodNotAllowed)
	}
}

// =====================================================================
// Admin — Levels
// =====================================================================

func adminLevelsHandler(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case http.MethodGet:
		subjectID := r.URL.Query().Get("subject_id")
		var rows *sql.Rows
		var err error
		if subjectID != "" {
			rows, err = db.Query(
				"SELECT id, subject_id, level_number, title, icon, stars_required FROM quiz_levels WHERE subject_id = ? ORDER BY level_number",
				subjectID)
		} else {
			rows, err = db.Query(
				"SELECT id, subject_id, level_number, title, icon, stars_required FROM quiz_levels ORDER BY subject_id, level_number")
		}
		if err != nil {
			w.WriteHeader(http.StatusInternalServerError)
			json.NewEncoder(w).Encode(Response{Error: "Database error"})
			return
		}
		defer rows.Close()
		levels := []AdminLevel{}
		for rows.Next() {
			var l AdminLevel
			rows.Scan(&l.ID, &l.SubjectID, &l.LevelNumber, &l.Title, &l.Icon, &l.StarsRequired)
			levels = append(levels, l)
		}
		json.NewEncoder(w).Encode(Response{Message: "Levels retrieved", Data: levels})

	case http.MethodPost:
		var l AdminLevel
		if err := json.NewDecoder(r.Body).Decode(&l); err != nil {
			w.WriteHeader(http.StatusBadRequest)
			json.NewEncoder(w).Encode(Response{Error: "Invalid request body"})
			return
		}
		if l.SubjectID == "" || l.Title == "" || l.LevelNumber == 0 {
			w.WriteHeader(http.StatusBadRequest)
			json.NewEncoder(w).Encode(Response{Error: "subject_id, level_number and title are required"})
			return
		}
		if l.Icon == "" {
			l.Icon = "🎯"
		}
		result, err := db.Exec(
			"INSERT INTO quiz_levels (subject_id, level_number, title, icon, stars_required) VALUES (?, ?, ?, ?, ?)",
			l.SubjectID, l.LevelNumber, l.Title, l.Icon, l.StarsRequired)
		if err != nil {
			w.WriteHeader(http.StatusInternalServerError)
			json.NewEncoder(w).Encode(Response{Error: "Failed to create level"})
			return
		}
		id, _ := result.LastInsertId()
		l.ID = int(id)
		w.WriteHeader(http.StatusCreated)
		json.NewEncoder(w).Encode(Response{Message: "Level created", Data: l})

	default:
		w.WriteHeader(http.StatusMethodNotAllowed)
	}
}

// =====================================================================
// Admin — Questions
// =====================================================================

func adminQuestionsHandler(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case http.MethodGet:
		levelIDStr := r.URL.Query().Get("level_id")
		if levelIDStr == "" {
			w.WriteHeader(http.StatusBadRequest)
			json.NewEncoder(w).Encode(Response{Error: "level_id is required"})
			return
		}
		rows, err := db.Query(
			`SELECT id, level_id, question_text, COALESCE(image_url,''), option_a, option_b, option_c, option_d,
			        correct_index, COALESCE(fun_fact,''), sort_order
			 FROM quiz_questions WHERE level_id = ? ORDER BY sort_order`, levelIDStr)
		if err != nil {
			w.WriteHeader(http.StatusInternalServerError)
			json.NewEncoder(w).Encode(Response{Error: "Database error"})
			return
		}
		defer rows.Close()
		questions := []AdminQuestion{}
		for rows.Next() {
			var q AdminQuestion
			rows.Scan(&q.ID, &q.LevelID, &q.QuestionText, &q.ImageURL,
				&q.OptionA, &q.OptionB, &q.OptionC, &q.OptionD,
				&q.CorrectIndex, &q.FunFact, &q.SortOrder)
			questions = append(questions, q)
		}
		json.NewEncoder(w).Encode(Response{Message: "Questions retrieved", Data: questions})

	case http.MethodPost:
		var req BatchQuestionsRequest
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			w.WriteHeader(http.StatusBadRequest)
			json.NewEncoder(w).Encode(Response{Error: "Invalid request body"})
			return
		}
		if req.LevelID == 0 || len(req.Questions) == 0 {
			w.WriteHeader(http.StatusBadRequest)
			json.NewEncoder(w).Encode(Response{Error: "level_id and questions are required"})
			return
		}
		tx, err := db.Begin()
		if err != nil {
			w.WriteHeader(http.StatusInternalServerError)
			json.NewEncoder(w).Encode(Response{Error: "Transaction error"})
			return
		}
		for i, q := range req.Questions {
			if q.OptionA == "" || q.OptionB == "" || q.OptionC == "" || q.OptionD == "" {
				tx.Rollback()
				w.WriteHeader(http.StatusBadRequest)
				json.NewEncoder(w).Encode(Response{Error: fmt.Sprintf("Question %d: all 4 options are required", i+1)})
				return
			}
			_, err := tx.Exec(
				`INSERT INTO quiz_questions (level_id, question_text, image_url, option_a, option_b, option_c, option_d, correct_index, fun_fact, sort_order)
				 VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
				req.LevelID, q.QuestionText, q.ImageURL, q.OptionA, q.OptionB, q.OptionC, q.OptionD, q.CorrectIndex, q.FunFact, i)
			if err != nil {
				tx.Rollback()
				w.WriteHeader(http.StatusInternalServerError)
				json.NewEncoder(w).Encode(Response{Error: "Failed to save questions"})
				return
			}
		}
		if err := tx.Commit(); err != nil {
			w.WriteHeader(http.StatusInternalServerError)
			json.NewEncoder(w).Encode(Response{Error: "Commit failed"})
			return
		}
		json.NewEncoder(w).Encode(Response{
			Message: fmt.Sprintf("%d questions saved", len(req.Questions)),
			Data:    map[string]int{"level_id": req.LevelID, "count": len(req.Questions)},
		})

	default:
		w.WriteHeader(http.StatusMethodNotAllowed)
	}
}

// =====================================================================
// Admin — Full Quiz
// =====================================================================

func adminFullQuizHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		w.WriteHeader(http.StatusMethodNotAllowed)
		return
	}
	subjectID := r.URL.Query().Get("subject_id")
	if subjectID == "" {
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(Response{Error: "subject_id is required"})
		return
	}
	var subject AdminSubject
	err := db.QueryRow("SELECT id, name, emoji, gradient_start, gradient_end FROM quiz_subjects WHERE id = ?", subjectID).
		Scan(&subject.ID, &subject.Name, &subject.Emoji, &subject.GradientStart, &subject.GradientEnd)
	if err != nil {
		w.WriteHeader(http.StatusNotFound)
		json.NewEncoder(w).Encode(Response{Error: "Subject not found"})
		return
	}
	levelRows, err := db.Query(
		"SELECT id, subject_id, level_number, title, icon, stars_required FROM quiz_levels WHERE subject_id = ? ORDER BY level_number",
		subjectID)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		return
	}
	defer levelRows.Close()
	result := FullQuizSubject{AdminSubject: subject, Levels: []FullQuizLevel{}}
	for levelRows.Next() {
		var l AdminLevel
		levelRows.Scan(&l.ID, &l.SubjectID, &l.LevelNumber, &l.Title, &l.Icon, &l.StarsRequired)
		qRows, err := db.Query(
			`SELECT id, level_id, question_text, COALESCE(image_url,''), option_a, option_b, option_c, option_d,
			        correct_index, COALESCE(fun_fact,''), sort_order
			 FROM quiz_questions WHERE level_id = ? ORDER BY sort_order`, l.ID)
		if err != nil {
			continue
		}
		questions := []AdminQuestion{}
		for qRows.Next() {
			var q AdminQuestion
			qRows.Scan(&q.ID, &q.LevelID, &q.QuestionText, &q.ImageURL,
				&q.OptionA, &q.OptionB, &q.OptionC, &q.OptionD,
				&q.CorrectIndex, &q.FunFact, &q.SortOrder)
			questions = append(questions, q)
		}
		qRows.Close()
		result.Levels = append(result.Levels, FullQuizLevel{AdminLevel: l, Questions: questions})
	}
	json.NewEncoder(w).Encode(Response{Message: "Quiz retrieved", Data: result})
}

// =====================================================================
// AI Chat
// =====================================================================

func aiChatHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		w.WriteHeader(http.StatusMethodNotAllowed)
		return
	}
	var req ChatRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(Response{Error: "Invalid request"})
		return
	}
	apiKey := os.Getenv("GROQ_API_KEY")
	if apiKey == "" {
		w.WriteHeader(http.StatusInternalServerError)
		json.NewEncoder(w).Encode(Response{Error: "AI service configuration error"})
		return
	}
	groqBody := GroqRequest{
		Model: "llama-3.3-70b-versatile",
		Messages: []GroqMessage{
			{Role: "system", Content: "Your name is Mindie. You are a friendly and encouraging AI buddy for the 'Little Minds' educational app. Your goal is to help kids learn and stay curious. Respond warmly and creatively in English, Sinhala, or Singlish."},
			{Role: "user", Content: req.Message},
		},
	}
	bodyBytes, _ := json.Marshal(groqBody)
	apiReq, _ := http.NewRequest("POST", "https://api.groq.com/openai/v1/chat/completions", strings.NewReader(string(bodyBytes)))
	apiReq.Header.Set("Authorization", "Bearer "+apiKey)
	apiReq.Header.Set("Content-Type", "application/json")
	client := &http.Client{Timeout: 15 * time.Second}
	resp, err := client.Do(apiReq)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		json.NewEncoder(w).Encode(Response{Error: "AI service is temporarily unavailable"})
		return
	}
	defer resp.Body.Close()
	var groqResp GroqResponse
	if err := json.NewDecoder(resp.Body).Decode(&groqResp); err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		return
	}
	if len(groqResp.Choices) > 0 {
		json.NewEncoder(w).Encode(map[string]string{"reply": groqResp.Choices[0].Message.Content})
	} else {
		json.NewEncoder(w).Encode(map[string]string{"reply": "Mindie is thinking hard! Please try again in a moment. 🦄"})
	}
}

// =====================================================================
// Admin — Jigsaw Puzzles  (table: puzzles)
// =====================================================================

func adminJigsawPuzzlesHandler(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case http.MethodGet:
		rows, err := db.Query("SELECT id, title, image_url, piece_count, category, difficulty, created_at FROM puzzles ORDER BY id DESC")
		if err != nil {
			w.WriteHeader(http.StatusInternalServerError)
			json.NewEncoder(w).Encode(Response{Error: "Database error"})
			return
		}
		defer rows.Close()
		puzzles := []JigsawPuzzle{}
		for rows.Next() {
			var p JigsawPuzzle
			rows.Scan(&p.ID, &p.Title, &p.ImageURL, &p.PieceCount, &p.Category, &p.Difficulty, &p.CreatedAt)
			puzzles = append(puzzles, p)
		}
		json.NewEncoder(w).Encode(Response{Message: "Jigsaw puzzles retrieved", Data: puzzles})

	case http.MethodPost:
		var p JigsawPuzzle
		if err := json.NewDecoder(r.Body).Decode(&p); err != nil {
			w.WriteHeader(http.StatusBadRequest)
			json.NewEncoder(w).Encode(Response{Error: "Invalid request body"})
			return
		}
		if p.Title == "" || p.ImageURL == "" {
			w.WriteHeader(http.StatusBadRequest)
			json.NewEncoder(w).Encode(Response{Error: "title and image_url are required"})
			return
		}
		if p.PieceCount == 0 {
			p.PieceCount = 16
		}
		if p.Category == "" {
			p.Category = "General"
		}
		if p.Difficulty == "" {
			p.Difficulty = "Medium"
		}
		result, err := db.Exec("INSERT INTO puzzles (title, image_url, piece_count, category, difficulty) VALUES (?, ?, ?, ?, ?)",
			p.Title, p.ImageURL, p.PieceCount, p.Category, p.Difficulty)
		if err != nil {
			w.WriteHeader(http.StatusInternalServerError)
			json.NewEncoder(w).Encode(Response{Error: "Failed to create puzzle"})
			return
		}
		id, _ := result.LastInsertId()
		p.ID = int(id)
		w.WriteHeader(http.StatusCreated)
		json.NewEncoder(w).Encode(Response{Message: "Jigsaw puzzle created", Data: p})

	case http.MethodDelete:
		idStr := r.URL.Query().Get("id")
		if idStr == "" {
			w.WriteHeader(http.StatusBadRequest)
			json.NewEncoder(w).Encode(Response{Error: "id is required"})
			return
		}
		db.Exec("DELETE FROM puzzles WHERE id = ?", idStr)
		json.NewEncoder(w).Encode(Response{Message: "Puzzle deleted"})

	default:
		w.WriteHeader(http.StatusMethodNotAllowed)
	}
}

// =====================================================================
// Public — Jigsaw Puzzles
// =====================================================================

func jigsawPuzzlesPublicHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	if r.Method != http.MethodGet {
		w.WriteHeader(http.StatusMethodNotAllowed)
		return
	}
	category := r.URL.Query().Get("category")
	var rows *sql.Rows
	var err error
	if category != "" {
		rows, err = db.Query("SELECT id, title, image_url, piece_count, category, difficulty, created_at FROM puzzles WHERE category = ? ORDER BY id DESC", category)
	} else {
		rows, err = db.Query("SELECT id, title, image_url, piece_count, category, difficulty, created_at FROM puzzles ORDER BY id DESC")
	}
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		json.NewEncoder(w).Encode(Response{Error: "Database error"})
		return
	}
	defer rows.Close()
	puzzles := []JigsawPuzzle{}
	for rows.Next() {
		var p JigsawPuzzle
		rows.Scan(&p.ID, &p.Title, &p.ImageURL, &p.PieceCount, &p.Category, &p.Difficulty, &p.CreatedAt)
		puzzles = append(puzzles, p)
	}
	json.NewEncoder(w).Encode(Response{Message: "Jigsaw puzzles retrieved", Data: puzzles})
}

// =====================================================================
// Admin — Crossword Puzzles  (table: crossword_puzzles)
// GET    /admin/crosswords            list all
// POST   /admin/crosswords            create
// GET    /admin/crosswords/{id}       get one with full data
// PUT    /admin/crosswords/{id}       update
// DELETE /admin/crosswords/{id}       delete
// =====================================================================

func adminCrosswordsHandler(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case http.MethodGet:
		rows, err := db.Query(
			`SELECT id, title, category, difficulty, grid_rows, grid_cols, timer_minutes, created_at
			 FROM crossword_puzzles ORDER BY id DESC`)
		if err != nil {
			log.Println("adminCrosswordsHandler GET error:", err)
			w.WriteHeader(http.StatusInternalServerError)
			json.NewEncoder(w).Encode(Response{Error: "Database error: " + err.Error()})
			return
		}
		defer rows.Close()
		puzzles := []map[string]interface{}{}
		for rows.Next() {
			var id, gridRows, gridCols, timerMinutes int
			var title, category, difficulty, createdAt string
			rows.Scan(&id, &title, &category, &difficulty, &gridRows, &gridCols, &timerMinutes, &createdAt)
			puzzles = append(puzzles, map[string]interface{}{
				"id":           id,
				"title":        title,
				"category":     category,
				"difficulty":   difficulty,
				"rows":         gridRows,
				"cols":         gridCols,
				"timerMinutes": timerMinutes,
				"created_at":   createdAt,
			})
		}
		json.NewEncoder(w).Encode(Response{Message: "Crosswords retrieved", Data: puzzles})

	case http.MethodPost:
		var p CrosswordPuzzle
		if err := json.NewDecoder(r.Body).Decode(&p); err != nil {
			w.WriteHeader(http.StatusBadRequest)
			json.NewEncoder(w).Encode(Response{Error: "Invalid request body"})
			return
		}
		if p.Title == "" {
			w.WriteHeader(http.StatusBadRequest)
			json.NewEncoder(w).Encode(Response{Error: "title is required"})
			return
		}
		if p.Category == "" {
			p.Category = "General"
		}
		if p.Difficulty == "" {
			p.Difficulty = "Medium"
		}
		if p.Rows == 0 {
			p.Rows = 10
		}
		if p.Cols == 0 {
			p.Cols = 10
		}
		if p.TimerMinutes == 0 {
			p.TimerMinutes = 10
		}
		gridBytes, _ := json.Marshal(p.GridData)
		acrossBytes, _ := json.Marshal(p.AcrossClues)
		downBytes, _ := json.Marshal(p.DownClues)
		result, err := db.Exec(
			`INSERT INTO crossword_puzzles (title, category, difficulty, grid_rows, grid_cols, grid_data, across_clues, down_clues, timer_minutes)
			 VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
			p.Title, p.Category, p.Difficulty, p.Rows, p.Cols,
			string(gridBytes), string(acrossBytes), string(downBytes), p.TimerMinutes)
		if err != nil {
			log.Println("adminCrosswordsHandler insert:", err)
			w.WriteHeader(http.StatusInternalServerError)
			json.NewEncoder(w).Encode(Response{Error: "Failed to create crossword"})
			return
		}
		id, _ := result.LastInsertId()
		p.ID = int(id)
		w.WriteHeader(http.StatusCreated)
		json.NewEncoder(w).Encode(Response{Message: "Crossword created", Data: map[string]interface{}{
			"id": p.ID, "title": p.Title,
		}})

	default:
		w.WriteHeader(http.StatusMethodNotAllowed)
	}
}

func adminCrosswordDetailHandler(w http.ResponseWriter, r *http.Request) {
	idStr := strings.TrimPrefix(r.URL.Path, "/admin/crosswords/")
	if idStr == "" {
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(Response{Error: "id required"})
		return
	}

	switch r.Method {
	case http.MethodGet:
		p, err := fetchCrossword(idStr)
		if err == sql.ErrNoRows {
			w.WriteHeader(http.StatusNotFound)
			json.NewEncoder(w).Encode(Response{Error: "Crossword not found"})
			return
		}
		if err != nil {
			w.WriteHeader(http.StatusInternalServerError)
			json.NewEncoder(w).Encode(Response{Error: "Database error"})
			return
		}
		json.NewEncoder(w).Encode(Response{Message: "Crossword retrieved", Data: p})

	case http.MethodPut:
		var p CrosswordPuzzle
		if err := json.NewDecoder(r.Body).Decode(&p); err != nil {
			w.WriteHeader(http.StatusBadRequest)
			json.NewEncoder(w).Encode(Response{Error: "Invalid request body"})
			return
		}
		gridBytes, _ := json.Marshal(p.GridData)
		acrossBytes, _ := json.Marshal(p.AcrossClues)
		downBytes, _ := json.Marshal(p.DownClues)
		_, err := db.Exec(
			`UPDATE crossword_puzzles SET title=?, category=?, difficulty=?, grid_rows=?, grid_cols=?,
			 grid_data=?, across_clues=?, down_clues=?, timer_minutes=? WHERE id=?`,
			p.Title, p.Category, p.Difficulty, p.Rows, p.Cols,
			string(gridBytes), string(acrossBytes), string(downBytes), p.TimerMinutes, idStr)
		if err != nil {
			w.WriteHeader(http.StatusInternalServerError)
			json.NewEncoder(w).Encode(Response{Error: "Failed to update crossword"})
			return
		}
		json.NewEncoder(w).Encode(Response{Message: "Crossword updated"})

	case http.MethodDelete:
		db.Exec("DELETE FROM crossword_puzzles WHERE id = ?", idStr)
		json.NewEncoder(w).Encode(Response{Message: "Crossword deleted"})

	default:
		w.WriteHeader(http.StatusMethodNotAllowed)
	}
}

func fetchCrossword(id string) (*CrosswordPuzzle, error) {
	var p CrosswordPuzzle
	var gridJSON, acrossJSON, downJSON string
	err := db.QueryRow(
		`SELECT id, title, category, difficulty, grid_rows, grid_cols, grid_data, across_clues, down_clues, timer_minutes
		 FROM crossword_puzzles WHERE id=?`, id,
	).Scan(&p.ID, &p.Title, &p.Category, &p.Difficulty, &p.Rows, &p.Cols,
		&gridJSON, &acrossJSON, &downJSON, &p.TimerMinutes)
	if err != nil {
		return nil, err
	}
	if gridJSON == "" || gridJSON == "null" {
		gridJSON = "[]"
	}
	if acrossJSON == "" || acrossJSON == "null" {
		acrossJSON = "[]"
	}
	if downJSON == "" || downJSON == "null" {
		downJSON = "[]"
	}
	json.Unmarshal([]byte(gridJSON), &p.GridData)
	json.Unmarshal([]byte(acrossJSON), &p.AcrossClues)
	json.Unmarshal([]byte(downJSON), &p.DownClues)
	return &p, nil
}

// =====================================================================
// Public — Crosswords
// =====================================================================

func crosswordsPublicHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	if r.Method != http.MethodGet {
		w.WriteHeader(http.StatusMethodNotAllowed)
		return
	}
	category := r.URL.Query().Get("category")
	difficulty := r.URL.Query().Get("difficulty")
	query := `SELECT id, title, category, difficulty, grid_rows, grid_cols, timer_minutes FROM crossword_puzzles`
	args := []interface{}{}
	where := []string{}
	if category != "" {
		where = append(where, "category = ?")
		args = append(args, category)
	}
	if difficulty != "" {
		where = append(where, "difficulty = ?")
		args = append(args, difficulty)
	}
	if len(where) > 0 {
		query += " WHERE " + strings.Join(where, " AND ")
	}
	query += " ORDER BY id DESC"
	rows, err := db.Query(query, args...)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		json.NewEncoder(w).Encode(Response{Error: "Database error"})
		return
	}
	defer rows.Close()
	puzzles := []map[string]interface{}{}
	for rows.Next() {
		var id, gridRows, gridCols, timerMinutes int
		var title, category, difficulty string
		rows.Scan(&id, &title, &category, &difficulty, &gridRows, &gridCols, &timerMinutes)
		puzzles = append(puzzles, map[string]interface{}{
			"id": id, "title": title, "category": category, "difficulty": difficulty,
			"rows": gridRows, "cols": gridCols, "timerMinutes": timerMinutes,
		})
	}
	json.NewEncoder(w).Encode(Response{Message: "Crosswords retrieved", Data: puzzles})
}

func crosswordPublicDetailHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	if r.Method != http.MethodGet {
		w.WriteHeader(http.StatusMethodNotAllowed)
		return
	}
	idStr := strings.TrimPrefix(r.URL.Path, "/crosswords/")
	if idStr == "" {
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(Response{Error: "id required"})
		return
	}
	p, err := fetchCrossword(idStr)
	if err == sql.ErrNoRows {
		w.WriteHeader(http.StatusNotFound)
		json.NewEncoder(w).Encode(Response{Error: "Crossword not found"})
		return
	}
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		json.NewEncoder(w).Encode(Response{Error: "Database error"})
		return
	}
	json.NewEncoder(w).Encode(Response{Message: "Crossword retrieved", Data: p})
}

// =====================================================================
// Admin — Stories
// =====================================================================

func adminStoriesHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	switch r.Method {
	case http.MethodGet:
		rows, err := db.Query(
			`SELECT s.id, s.title, s.author, s.description, s.cover_url, s.cover_emoji,
			        s.category, s.difficulty, s.age_range, s.created_at, COUNT(p.id) AS page_count
			 FROM stories s LEFT JOIN story_pages p ON p.story_id = s.id
			 GROUP BY s.id ORDER BY s.id DESC`)
		if err != nil {
			w.WriteHeader(http.StatusInternalServerError)
			json.NewEncoder(w).Encode(Response{Error: "Database error"})
			return
		}
		defer rows.Close()
		stories := []Story{}
		for rows.Next() {
			var s Story
			rows.Scan(&s.ID, &s.Title, &s.Author, &s.Description, &s.CoverURL,
				&s.CoverEmoji, &s.Category, &s.Difficulty, &s.AgeRange, &s.CreatedAt, &s.PageCount)
			stories = append(stories, s)
		}
		json.NewEncoder(w).Encode(Response{Message: "Stories retrieved", Data: stories})

	case http.MethodPost:
		var req struct {
			Title       string      `json:"title"`
			Author      string      `json:"author"`
			Description string      `json:"description"`
			CoverURL    string      `json:"cover_url"`
			CoverEmoji  string      `json:"cover_emoji"`
			Category    string      `json:"category"`
			Difficulty  string      `json:"difficulty"`
			AgeRange    string      `json:"age_range"`
			Pages       []StoryPage `json:"pages"`
		}
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			w.WriteHeader(http.StatusBadRequest)
			json.NewEncoder(w).Encode(Response{Error: "Invalid request body"})
			return
		}
		if req.Title == "" || req.Author == "" {
			w.WriteHeader(http.StatusBadRequest)
			json.NewEncoder(w).Encode(Response{Error: "title and author are required"})
			return
		}
		if req.Category == "" {
			req.Category = "General"
		}
		if req.Difficulty == "" {
			req.Difficulty = "Easy"
		}
		if req.AgeRange == "" {
			req.AgeRange = "4-8"
		}
		if req.CoverEmoji == "" {
			req.CoverEmoji = "📖"
		}
		tx, err := db.Begin()
		if err != nil {
			w.WriteHeader(http.StatusInternalServerError)
			return
		}
		result, err := tx.Exec(
			`INSERT INTO stories (title, author, description, cover_url, cover_emoji, category, difficulty, age_range)
			 VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
			req.Title, req.Author, req.Description, req.CoverURL,
			req.CoverEmoji, req.Category, req.Difficulty, req.AgeRange)
		if err != nil {
			tx.Rollback()
			w.WriteHeader(http.StatusInternalServerError)
			json.NewEncoder(w).Encode(Response{Error: "Failed to create story"})
			return
		}
		storyID, _ := result.LastInsertId()
		for i, p := range req.Pages {
			if p.Body == "" {
				continue
			}
			pageNum := p.PageNumber
			if pageNum == 0 {
				pageNum = i + 1
			}
			_, err := tx.Exec(
				`INSERT INTO story_pages (story_id, page_number, title, body, image_url) VALUES (?, ?, ?, ?, ?)`,
				storyID, pageNum, p.Title, p.Body, p.ImageURL)
			if err != nil {
				tx.Rollback()
				w.WriteHeader(http.StatusInternalServerError)
				json.NewEncoder(w).Encode(Response{Error: fmt.Sprintf("Failed to save page %d", i+1)})
				return
			}
		}
		tx.Commit()
		w.WriteHeader(http.StatusCreated)
		json.NewEncoder(w).Encode(Response{Message: "Story created", Data: map[string]interface{}{"id": storyID, "title": req.Title}})

	case http.MethodDelete:
		idStr := r.URL.Query().Get("id")
		if idStr == "" {
			w.WriteHeader(http.StatusBadRequest)
			return
		}
		db.Exec("DELETE FROM stories WHERE id = ?", idStr)
		json.NewEncoder(w).Encode(Response{Message: "Story deleted"})

	default:
		w.WriteHeader(http.StatusMethodNotAllowed)
	}
}

func adminStoryDetailHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	if r.Method != http.MethodGet {
		w.WriteHeader(http.StatusMethodNotAllowed)
		return
	}
	idStr := strings.TrimPrefix(r.URL.Path, "/admin/stories/")
	var s Story
	err := db.QueryRow(
		`SELECT id, title, author, description, cover_url, cover_emoji, category, difficulty, age_range, created_at
		 FROM stories WHERE id = ?`, idStr,
	).Scan(&s.ID, &s.Title, &s.Author, &s.Description, &s.CoverURL,
		&s.CoverEmoji, &s.Category, &s.Difficulty, &s.AgeRange, &s.CreatedAt)
	if err != nil {
		w.WriteHeader(http.StatusNotFound)
		json.NewEncoder(w).Encode(Response{Error: "Story not found"})
		return
	}
	rows, err := db.Query(
		`SELECT id, story_id, page_number, title, body, COALESCE(image_url,'') FROM story_pages WHERE story_id = ? ORDER BY page_number`, s.ID)
	if err == nil {
		defer rows.Close()
		for rows.Next() {
			var p StoryPage
			rows.Scan(&p.ID, &p.StoryID, &p.PageNumber, &p.Title, &p.Body, &p.ImageURL)
			s.Pages = append(s.Pages, p)
		}
	}
	json.NewEncoder(w).Encode(Response{Message: "Story retrieved", Data: s})
}

func storiesPublicHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	if r.Method != http.MethodGet {
		w.WriteHeader(http.StatusMethodNotAllowed)
		return
	}
	category := r.URL.Query().Get("category")
	difficulty := r.URL.Query().Get("difficulty")
	query := `SELECT s.id, s.title, s.author, s.description, s.cover_url, s.cover_emoji,
	                 s.category, s.difficulty, s.age_range, s.created_at, COUNT(p.id) AS page_count
	          FROM stories s LEFT JOIN story_pages p ON p.story_id = s.id`
	args := []interface{}{}
	where := []string{}
	if category != "" {
		where = append(where, "s.category = ?")
		args = append(args, category)
	}
	if difficulty != "" {
		where = append(where, "s.difficulty = ?")
		args = append(args, difficulty)
	}
	if len(where) > 0 {
		query += " WHERE " + strings.Join(where, " AND ")
	}
	query += " GROUP BY s.id ORDER BY s.id DESC"
	rows, err := db.Query(query, args...)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		return
	}
	defer rows.Close()
	stories := []Story{}
	for rows.Next() {
		var s Story
		rows.Scan(&s.ID, &s.Title, &s.Author, &s.Description, &s.CoverURL,
			&s.CoverEmoji, &s.Category, &s.Difficulty, &s.AgeRange, &s.CreatedAt, &s.PageCount)
		stories = append(stories, s)
	}
	json.NewEncoder(w).Encode(Response{Message: "Stories retrieved", Data: stories})
}

func storyPublicDetailHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	if r.Method != http.MethodGet {
		w.WriteHeader(http.StatusMethodNotAllowed)
		return
	}
	idStr := strings.TrimPrefix(r.URL.Path, "/stories/")
	var s Story
	err := db.QueryRow(
		`SELECT id, title, author, description, cover_url, cover_emoji, category, difficulty, age_range, created_at
		 FROM stories WHERE id = ?`, idStr,
	).Scan(&s.ID, &s.Title, &s.Author, &s.Description, &s.CoverURL,
		&s.CoverEmoji, &s.Category, &s.Difficulty, &s.AgeRange, &s.CreatedAt)
	if err != nil {
		w.WriteHeader(http.StatusNotFound)
		json.NewEncoder(w).Encode(Response{Error: "Story not found"})
		return
	}
	rows, err := db.Query(
		`SELECT id, story_id, page_number, title, body, COALESCE(image_url,'') FROM story_pages WHERE story_id = ? ORDER BY page_number`, s.ID)
	if err == nil {
		defer rows.Close()
		for rows.Next() {
			var p StoryPage
			rows.Scan(&p.ID, &p.StoryID, &p.PageNumber, &p.Title, &p.Body, &p.ImageURL)
			s.Pages = append(s.Pages, p)
		}
	}
	json.NewEncoder(w).Encode(Response{Message: "Story retrieved", Data: s})
}
