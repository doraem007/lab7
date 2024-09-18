<?php
// Allow Access-Control from any origin and specify allowed headers and methods
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: OPTIONS, GET, POST, PUT, DELETE");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

$link = mysqli_connect('localhost', 'root', '', 'lab7');
mysqli_set_charset($link, 'utf8');

// Get request method
$requestMethod = $_SERVER["REQUEST_METHOD"];

// GET METHOD
if ($requestMethod == 'GET') {
    if (isset($_GET['student_code']) && !empty($_GET['student_code'])) {
        $student_code = mysqli_real_escape_string($link, $_GET['student_code']);
        $sql = "SELECT * FROM student WHERE student_code = '$student_code'";
    } else {
        $sql = "SELECT * FROM student";
    }

    $result = mysqli_query($link, $sql);

    $arr = array();
    while ($row = mysqli_fetch_assoc($result)) {
        $arr[] = $row;
    }

    echo json_encode($arr);
}

// POST METHOD
elseif ($requestMethod == 'POST') {
    // Get POST data
    $data = json_decode(file_get_contents('php://input'), true);
    
    if (!empty($data)) {
        $student_code = mysqli_real_escape_string($link, $data['student_code']);
        $student_name = mysqli_real_escape_string($link, $data['student_name']);
        $gender = mysqli_real_escape_string($link, $data['gender']);
        
        $sql = "INSERT INTO student (student_code, student_name, gender) VALUES ('$student_code', '$student_name','$gender')";
        $result = mysqli_query($link, $sql);
        
        if ($result) {
            echo json_encode(['status' => 'ok', 'message' => 'Insert Data Complete']);
        } else {
            echo json_encode(['status' => 'error', 'message' => 'Error inserting data']);
        }
    }
}

// PUT METHOD
elseif ($requestMethod == 'PUT') {
    // Get PUT data
    $data = json_decode(file_get_contents('php://input'), true);
    
    if (!empty($data)) {
        $student_code = mysqli_real_escape_string($link, $data['student_code']);
        $student_name = mysqli_real_escape_string($link, $data['student_name']);
        $gender = mysqli_real_escape_string($link, $data['gender']);
        
        $sql = "UPDATE student SET student_name = '$student_name', gender = '$gender' WHERE student_code = '$student_code'";
        $result = mysqli_query($link, $sql);
        
        if ($result) {
            echo json_encode(['status' => 'ok', 'message' => 'Update Data Complete']);
        } else {
            echo json_encode(['status' => 'error', 'message' => 'Error updating data']);
        }
    }
}

// DELETE METHOD
elseif ($requestMethod == 'DELETE') {
    // Get DELETE data from query string
    if (isset($_GET['student_code'])) {
        $student_code = mysqli_real_escape_string($link, $_GET['student_code']);
        
        $sql = "DELETE FROM student WHERE student_code = '$student_code'";
        $result = mysqli_query($link, $sql);
        
        if ($result) {
            echo json_encode(['status' => 'ok', 'message' => 'Delete Data Complete']);
        } else {
            echo json_encode(['status' => 'error', 'message' => 'Error deleting data']);
        }
    } else {
        echo json_encode(['status' => 'error', 'message' => 'student_code not provided']);
    }
}


// Close database connection
mysqli_close($link);
?>
