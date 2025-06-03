<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include 'connection.php';

// Consultar los recursos de la biblioteca
$sql = "SELECT codigo, titulo, descripcion, autor, tipo, enlace, archivo_pdf, fecha_publicacion FROM biblioteca"; // Agregado fecha_publicacion
$result = $conn->query($sql);

$data = array();
if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $data[] = $row;
    }
    echo json_encode(array("success" => true, "data" => $data));
} else {
    echo json_encode(array("success" => false, "message" => "No hay recursos disponibles"));
}

$conn->close();
?>