<?php
session_start();

// Habilitar el manejo de errores
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// Cabeceras CORS
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");

include 'connection.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $rol = $_POST['rol'] ?? '';
    $nombre = $_POST['nombre'] ?? '';
    $correo = $_POST['correo'] ?? '';
    $codigo = $_POST['codigo'] ?? '';

    // Validar datos
    if (empty($rol) || empty($nombre) || empty($correo) || empty($codigo)) {
        echo json_encode(["success" => false, "message" => "Datos incompletos"]);
        exit;
    }

    // Verificar si el correo ya existe
    $checkEmailSql = "SELECT * FROM Usuario WHERE correo = ?";
    $stmt = $conn->prepare($checkEmailSql);
    if (!$stmt) {
        echo json_encode(["success" => false, "message" => "Error en la preparación de la consulta: " . $conn->error]);
        exit;
    }
    $stmt->bind_param("s", $correo);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        echo json_encode(["success" => false, "message" => "El correo ya está registrado"]);
        exit;
    }

    // Insertar el nuevo usuario
    $sql = "INSERT INTO Usuario (nombre, correo, codigo, rol, contraseña) VALUES (?, ?, ?, ?, ?)";
    $stmt = $conn->prepare($sql);
    if (!$stmt) {
        echo json_encode(["success" => false, "message" => "Error en la preparación de la consulta: " . $conn->error]);
        exit;
    }

    // Aquí puedes encriptar la contraseña si es necesario
    $contraseña = password_hash($codigo, PASSWORD_BCRYPT); // Usando el código como contraseña
    $stmt->bind_param("sssss", $nombre, $correo, $codigo, $rol, $contraseña);

    if ($stmt->execute()) {
        echo json_encode(["success" => true, "message" => "Registro exitoso"]);
    } else {
        echo json_encode(["success" => false, "message" => "Error al registrar"]);
    }

    $stmt->close();
} else {
    echo json_encode(["success" => false, "message" => "Método no soportado"]);
}

$conn->close();
?>