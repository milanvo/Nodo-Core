<!DOCTYPE html> 
<html> 

<head>
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1"> 
	<title>Delete values</title> 
	<link rel="stylesheet" href="http://code.jquery.com/mobile/1.0rc2/jquery.mobile-1.0rc2.min.css" />
	<script src="http://code.jquery.com/jquery-1.6.4.min.js"></script>
	<script src="http://code.jquery.com/mobile/1.0rc2/jquery.mobile-1.0rc2.min.js"></script>
</head> 

<body> 

<div data-role="page" data-theme="c">

	<div data-role="header">
		<h1></h1>
	</div><!-- /header -->

	<div data-role="content">	
		<h2>Delete value?</h2>
		<h4>The historical data of this value will also be deleted!</h4>
		<br>
		<a href="values_delete.php?id=<?php echo $_GET["id"];?> " data-role="button" data-inline="true" data-ajax="false">Yes</a>
		<a href="values.php" data-role="button" data-inline="true" data-ajax="false">No</a>
	</div><!-- /content -->
	
	
	
	
</div><!-- /page -->

</body>
</html>