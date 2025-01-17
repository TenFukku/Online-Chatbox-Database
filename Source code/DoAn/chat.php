<?php
    session_start();

    // Kiểm tra xem người dùng đã đăng nhập chưa
    if (!isset($_SESSION['username'])) {
        // Nếu chưa, chuyển hướng người dùng đến trang đăng nhập
        header("Location: login.php");
        exit();
    }

    // Kết nối đến cơ sở dữ liệu
    $servername = "localhost";
    $username = "root";
    $password = "phu3113";
    $database = "CHATROOM";

    $conn = mysqli_connect($servername, $username, $password, $database);

    // Kiểm tra kết nối
    if (!$conn) {
        die("Connection failed: " . mysqli_connect_error());
    }

    // Lấy thông tin người dùng từ session
    $user_id = $_SESSION['username'];

    // Lấy MAPC từ URL
    if (isset($_GET['group_id'])) {
        $group_id = $_GET['group_id'];

        // Kiểm tra xem người dùng đã tham gia vào phòng chat chưa
        $check_query = "SELECT * FROM ND_PC WHERE TAIKHOAN='$user_id' AND MAPC='$group_id'";
        $check_result = mysqli_query($conn, $check_query);

        if (mysqli_num_rows($check_result) == 0) {
            // Nếu chưa, thêm người dùng vào phòng chat
            $insert_query = "INSERT INTO ND_PC (TAIKHOAN, MAPC, QUYEN, NGAYTG) VALUES ('$user_id', '$group_id', 0, NOW())";
            $insert_result = mysqli_query($conn, $insert_query);

            if (!$insert_result) {
                // Nếu có lỗi khi thêm người dùng vào phòng chat, hiển thị thông báo lỗi
                echo "Đã xảy ra lỗi khi tham gia vào phòng chat.";
            }
        }
    }

?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chat Room</title>
    <link rel="stylesheet" href="assest/style.css">
    <link rel="stylesheet" href="assest/responsive.css">
</head>
<body>
    <div class="main">
        <div class="menu-container">
            <label class="menu-bar menu-item" for="sub-menu-checkbox">
                <i class="fa-solid fa-bars"></i>
            </label>
            <input type="checkbox" id="sub-menu-checkbox" style="display: none;">
            <label class="sub-menu-container" for="sub-menu-checkbox">
            </label>
            <div class="sub-menu-area"> 
                <a href="index.php">All rooms <i class="fa-solid fa-caret-right"></i></a>
                <div>
                    <h2>Your Rooms:</h2>
                    <ul id="your-rooms">
                        <?php
                            // Kết nối đến cơ sở dữ liệu
                            $servername = "localhost";
                            $username = "root";
                            $password = "phu3113";
                            $database = "CHATROOM";

                            $conn = mysqli_connect($servername, $username, $password, $database);

                            // Kiểm tra kết nối
                            if (!$conn) {
                                die("Connection failed: " . mysqli_connect_error());
                            }
                            $user_id = $_SESSION['username'];
                            // Truy vấn SQL để lấy danh sách nhóm chat từ cơ sở dữ liệu
                            $sql = "SELECT TENPC, PHONGCHAT.MAPC FROM PHONGCHAT JOIN ND_PC ON PHONGCHAT.MAPC = ND_PC.MAPC WHERE TAIKHOAN = '$user_id'";
                            $result = mysqli_query($conn, $sql);

                            if (mysqli_num_rows($result) > 0) {
                                // Duyệt qua từng dòng kết quả và hiển thị tên nhóm chat
                                while ($row = mysqli_fetch_assoc($result)) {
                                    echo "<li><a href='chat.php?group_id=" . $row['MAPC'] . "'>" . $row['TENPC'] . " <i class='fa-solid fa-caret-right'></i></a></li>";
                                }
                            } else {
                                // Không có nhóm chat nào trong cơ sở dữ liệu
                                echo "No group chats found.";
                            }

                            // Đóng kết nối
                            mysqli_close($conn);
                        ?>
                    </ul>
                </div>
            </div>
           
            <ul class="menu-item-container">
                <li class="menu-item">
                    <i class="fa-solid fa-user-group"></i>
                </li>
                <li class="menu-item">
                    <i class="fa-solid fa-bell"></i>
                </li>
                <li class="menu-item">
                    <i class="fa-solid fa-user"></i>
                    <ul class="sub-menu-item">
                        <li><a href="#">Profile</a></li>
                        <li><a href="login.php">Log out</a></li>
                    </ul>
                </li>
            </ul>
        </div>
        <div class="chat-container">
            <!-- Giao diện phòng chat -->
            <div class="chat-content">
            <!-- Hiển thị nội dung phòng chat -->
            <?php
                // Kiểm tra xem MAPC đã được truyền qua URL hay không
                if (isset($_GET['group_id'])) {
                    $group_id = $_GET['group_id'];
                    $servername = "localhost";
                    $username = "root";
                    $password = "phu3113";
                    $database = "CHATROOM";
                    if (!$conn) {
                        die("Connection failed: " . mysqli_connect_error());
                    }
                
                    $conn = mysqli_connect($servername, $username, $password, $database);
                    // Truy vấn SQL để lấy tin nhắn từ cơ sở dữ liệu
                    $message_query = "SELECT * FROM TINNHAN JOIN NGUOIDUNG ON TINNHAN.TAIKHOAN = NGUOIDUNG.TAIKHOAN WHERE MAPC='$group_id' ORDER BY NGAYGUI ASC";
                    $message_result = mysqli_query($conn, $message_query);

                    if ($message_result) {
                        // Kiểm tra xem có tin nhắn nào không
                        if (mysqli_num_rows($message_result) > 0) {
                            // Duyệt qua từng dòng kết quả và hiển thị tin nhắn
                            while ($message_row = mysqli_fetch_assoc($message_result)) {
                                echo "<div class='chat-post'>";
                                echo "<div>";
                                echo "<p>" . $message_row['TENND'] . "</p>";
                                echo "<p> sended at " . $message_row['NGAYGUI'] . "</p>";
                                echo "</div>";
                                echo "<p>" . $message_row['NOIDUNG'] . "</p>";
                                echo "</div>";
                            }
                        } else {
                            // Hiển thị thông báo nếu không có tin nhắn
                            echo "<div class='chat-post'><p>No messages yet.</p></div>";
                        }
                    } else {
                        // Hiển thị thông báo nếu có lỗi khi thực hiện truy vấn
                        echo "Error: " . mysqli_error($conn);
                    }
                } else {
                    // Hiển thị thông báo nếu MAPC không được truyền qua URL
                    echo "Group ID is missing.";
                }
            ?>
            </div>
            <div class="chat-sending">
                <form class="chat-form" action="send_message.php?group_id=<?php echo $group_id; ?>" method="POST" onsubmit="return validateMessage();">
                    <input id="message_content" type="text" name="message_content" placeholder="Type your message here">
                    <button type="submit" name="send_message"><i class="fa-solid fa-paper-plane"></i></button>
                </form>
            </div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="/assest/main.js"></script>
    <script>
       $(document).ready(function() {
            $('.menu-item').mouseenter(function() {
                $(this).children('.sub-menu-item').stop().slideDown(300).css({
                    'height': 'fit-content',
                    'display': 'block'
                });
            }).mouseleave(function() {
                $(this).children('.sub-menu-item').stop().slideUp(300).css({
                    'height': 'fit-content',
                    'display': 'block'
                });
            });
        });

    </script>
     <script>
        function validateMessage() {
            var messageContent = document.getElementById("message_content").value;
            if (messageContent.trim() === "") {
                alert("Vui lòng nhập tin nhắn!");
                return false;
            }
            return true;
        }
    </script>
</body>
</html>
