<!DOCTYPE html>

<html>
<head>
	<title>World Conflict Test</title>
	<meta charset='utf-8'>
	<link rel="stylesheet" type="text/css" href="css/style_hope.css">

	<link rel="stylesheet" type="text/css" href="https://cdnjs.cloudflare.com/ajax/libs/cookieconsent2/3.1.0/cookieconsent.min.css" />
	<script src="https://cdnjs.cloudflare.com/ajax/libs/cookieconsent2/3.1.0/cookieconsent.min.js"></script>
	<script>
	window.addEventListener("load", function(){
	window.cookieconsent.initialise({
	  "palette": {
	    "popup": {
	      "background": "#252e39"
	    },
	    "button": {
	      "background": "#14a7d0"
	    }
	  },
	  "theme": "classic",
	  "content": {
	    "message": "Cookies? Oh yeah... Well, guess what? I don't use them. But anyway, you're welcome to read the privacy notice of this website. Have fun!",
	    "href": "www.fortheloveofquote.com/privacy"
	  }
	})});
	</script>
</head>
<body>
	<div class="header" id="sticky_header">
		<p class="placeholder">This is just a placeholder.</p>
		<a href="index.php" class="page_title_link">For The Love of Quote</a><br>
		<p class="top_links_all">
		<a href="index.php" target="_blank">Home</a>
		<a href="about.html" target="_blank">About</a>
		<a href="contact.html" target="_blank">Contact</a>
		</p>
	</div>
	<hr>
	<div class="index_content">
		
		<!-- Slideshow container -->
		<div class="slideshow-container">

			<?php
				$db = mysqli_connect("localhost", "anna", "WeRt1234", "quotes_db");
				if (!$db) {
					die("Connection failed; " . mysqli_connect_error());
				}
				$sql = "SELECT * FROM quotes_img";
				$result = mysqli_query($db, $sql);
				$nrows = mysqli_num_rows($result);
				if (mysqli_num_rows($result) > 0 ) {
					while($row = mysqli_fetch_assoc($result)) {
						$quotes[] = $row;
					}
				}else {
					echo "0 results";
				}

				$quotes = array_reverse($quotes, true);

				$ln = 1;
				foreach($quotes as $quote) {
					echo '<div class="mySlides fade"><div class="numbertext">' . $ln . ' / ' . $nrows . '</div><img src="'. $quote["img_path"] . '" style="width:100%"></div>';
					$ln = $ln + 1;
				}
				mysqli_close($conn);
			?>

  			<!-- Next and previous buttons -->
  			<a class="prev" onclick="plusSlides(-1)">&#10094;</a>
  			<a class="next" onclick="plusSlides(1)">&#10095;</a>
		</div>

		<script>
			var slideIndex = 1;
			var t;
			showSlides(slideIndex);

			function plusSlides(n) {
			  slideIndex = slideIndex + n;
			  clearTimeout(t);
			  showSlides(slideIndex);
			  console.log(slideIndex);
			}

			function currentSlide(n) {
			  showSlides(slideIndex = n);
			}

			function showSlides(n) {
			  var i;
			  var slides = document.getElementsByClassName("mySlides");
			  if (n == undefined) {
			    n = ++slideIndex;
			  }
			  if (n > slides.length) {
			    slideIndex = 1
			  }
			  if (n < 1) {
			    slideIndex = slides.length
			  }

			  for (i = 0; i < slides.length; i++) {
			    slides[i].style.display = "none";
			  }

			  slides[slideIndex - 1].style.display = "block";
			  t = setTimeout(showSlides, 5000);
			}

		</script>

	</div>
	<hr>
	<div class="bottom_menu">
			<a href="impressum.html" target="_blank" class="bottom_menu_item">Imprint</a>
			<a href="privacy.html" target="_blank" class="bottom_menu_item">Privacy notice</a>
		</div>
</body>
</html>