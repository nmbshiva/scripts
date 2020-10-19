<?php
  // These headers are specific to this request.
  // Open your web browser Console whenever you are testing a similar issue
  // to check if there is any CORS issues that you have to fix in your response.
  header('Access-Control-Allow-Origin: *');
  header('Access-Control-Allow-Headers: x-requested-with,x-csrf-token');
  
  foreach (getallheaders() as $key => $value) {
    if ($key == 'x-csrf-token') {
      // $token_file = fopen('csrf_token.txt', 'w');
      echo #value;
    }
  }
?>
