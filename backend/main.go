package main

import (
	"encoding/json"
	"fmt"
	"log"
	"math/rand"
	"net/http"
	"strconv"
	"strings"
	"time"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

// Structs para autenticación
type LoginRequest struct {
	Email    string `json:"email" binding:"required"`
	Password string `json:"password" binding:"required"`
}

type LoginResponse struct {
	AccessToken string  `json:"access_token"`
	TokenType   string  `json:"token_type"`
	User        UserOut `json:"user"`
}

type VerifyTokenRequest struct {
	IDToken string `json:"id_token" binding:"required"`
}

type VerifyTokenResponse struct {
	UID     string `json:"uid"`
	Email   string `json:"email"`
	IsValid bool   `json:"is_valid"`
}

// Structs para usuarios
type UserOut struct {
	ID          string `json:"id"`
	Email       string `json:"email"`
	DisplayName string `json:"display_name"`
	Role        string `json:"role"`
	CreatedAt   string `json:"created_at"`
}

type UserCreate struct {
	Email       string `json:"email" binding:"required"`
	DisplayName string `json:"display_name" binding:"required"`
	Role        string `json:"role"`
	Password    string `json:"password" binding:"required"`
}

// Almacenamiento en memoria (para testing)
var users = make(map[string]UserOut)
var userCredentials = make(map[string]string) // email -> password
var verificationCodes = make(map[string]string) // email -> código

func main() {
	// Configurar Gin
	router := gin.Default()

	// Configurar CORS
	config := cors.DefaultConfig()
	config.AllowAllOrigins = true
	config.AllowMethods = []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"}
	config.AllowHeaders = []string{"*"}
	router.Use(cors.New(config))

	// Crear usuario de prueba
	initTestData()

	// Rutas
	v1 := router.Group("/api/v1")
	{
		// Auth
		auth := v1.Group("/auth")
		{
			auth.POST("/token", handleLogin)
			auth.POST("/verify-token", handleVerifyToken)
		}

		// Users
		users := v1.Group("/users")
		{
			users.GET("", handleGetUsers)
			users.POST("", handleCreateUser)
			users.GET("/:id", handleGetUser)
			users.PUT("/:id", handleUpdateUser)
			users.DELETE("/:id", handleDeleteUser)
		}
	}

	// Health check
	router.GET("/healthz", func(c *gin.Context) {
		c.String(http.StatusOK, "ok")
	})

	// Iniciar servidor
	log.Println("TrailoGo API iniciando en http://127.0.0.1:8080")
	log.Fatal(http.ListenAndServe(":8080", router))
}

func initTestData() {
	// Usuario de prueba
	testUser := UserOut{
		ID:          "test123",
		Email:       "test@example.com",
		DisplayName: "Usuario Test",
		Role:        "client",
		CreatedAt:   time.Now().Format(time.RFC3339),
	}
	
	users[testUser.ID] = testUser
	userCredentials[testUser.Email] = "password123"
	
	log.Printf("Usuario de prueba creado: %s / %s", testUser.Email, "password123")
}

func handleLogin(c *gin.Context) {
	var req LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Verificar credenciales
	if password, exists := userCredentials[req.Email]; !exists || password != req.Password {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid email or password"})
		return
	}

	// Buscar usuario
	var user UserOut
	for _, u := range users {
		if u.Email == req.Email {
			user = u
			break
		}
	}

	// Generar código de verificación
	code := generateVerificationCode()
	verificationCodes[req.Email] = code
	
	log.Printf("Código de verificación para %s: %s", req.Email, code)
	fmt.Printf("\n🔐 CÓDIGO DE VERIFICACIÓN 🔐\n")
	fmt.Printf("Email: %s\n", req.Email)
	fmt.Printf("Código: %s\n", code)
	fmt.Printf("================================\n\n")

	// Respuesta de login
	response := LoginResponse{
		AccessToken: "bearer_token_" + user.ID,
		TokenType:   "bearer",
		User:        user,
	}

	c.JSON(http.StatusOK, response)
}

func handleVerifyToken(c *gin.Context) {
	var req VerifyTokenRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Obtener email del token de autorización
	authHeader := c.GetHeader("Authorization")
	email := extractEmailFromAuthHeader(authHeader)
	
	if email == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid authorization header"})
		return
	}

	// Verificar código
	expectedCode, exists := verificationCodes[email]
	isValid := exists && expectedCode == req.IDToken

	var user UserOut
	for _, u := range users {
		if u.Email == email {
			user = u
			break
		}
	}

	if isValid {
		// Limpiar código usado
		delete(verificationCodes, email)
	}

	response := VerifyTokenResponse{
		UID:     user.ID,
		Email:   email,
		IsValid: isValid,
	}

	c.JSON(http.StatusOK, response)
}

func handleCreateUser(c *gin.Context) {
	var req UserCreate
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Verificar si el email ya existe
	for _, user := range users {
		if user.Email == req.Email {
			c.JSON(http.StatusConflict, gin.H{"error": "Email already exists"})
			return
		}
	}

	// Crear nuevo usuario
	newUser := UserOut{
		ID:          "user_" + strconv.Itoa(rand.Intn(100000)),
		Email:       req.Email,
		DisplayName: req.DisplayName,
		Role:        req.Role,
		CreatedAt:   time.Now().Format(time.RFC3339),
	}

	if newUser.Role == "" {
		newUser.Role = "client"
	}

	users[newUser.ID] = newUser
	userCredentials[req.Email] = req.Password

	c.JSON(http.StatusCreated, newUser)
}

func handleGetUsers(c *gin.Context) {
	userList := make([]UserOut, 0, len(users))
	for _, user := range users {
		userList = append(userList, user)
	}
	c.JSON(http.StatusOK, userList)
}

func handleGetUser(c *gin.Context) {
	id := c.Param("id")
	user, exists := users[id]
	if !exists {
		c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
		return
	}
	c.JSON(http.StatusOK, user)
}

func handleUpdateUser(c *gin.Context) {
	id := c.Param("id")
	user, exists := users[id]
	if !exists {
		c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
		return
	}

	var updateData map[string]interface{}
	if err := c.ShouldBindJSON(&updateData); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Actualizar campos permitidos
	if displayName, ok := updateData["display_name"].(string); ok {
		user.DisplayName = displayName
	}

	users[id] = user
	c.JSON(http.StatusOK, user)
}

func handleDeleteUser(c *gin.Context) {
	id := c.Param("id")
	if _, exists := users[id]; !exists {
		c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
		return
	}

	delete(users, id)
	c.JSON(http.StatusNoContent, nil)
}

func generateVerificationCode() string {
	return fmt.Sprintf("%06d", rand.Intn(1000000))
}

func extractEmailFromAuthHeader(authHeader string) string {
	if authHeader == "" {
		return ""
	}

	// Formato: "Bearer bearer_token_user_id"
	parts := strings.Split(authHeader, " ")
	if len(parts) != 2 || parts[0] != "Bearer" {
		return ""
	}

	token := parts[1]
	if !strings.HasPrefix(token, "bearer_token_") {
		return ""
	}

	// Extraer user_id del token
	userID := strings.TrimPrefix(token, "bearer_token_")
	
	// Buscar email por user_id
	if user, exists := users[userID]; exists {
		return user.Email
	}

	return ""
}