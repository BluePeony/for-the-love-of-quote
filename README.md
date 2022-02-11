# For the Love of Quote

This project constists of a website, Ruby scripts and a MySQL database which contains quotes and corresponding authors.<br>
A user can add a new quote by running a script on the command line. Prior to save this quote the script ensures that this quote does not already exist in the database.<br>
A second script randomly chooses a yet unpublished quote from the database as well as a background picture from a selection of images. It then renders the quote to be placed in the centre of the picture and saves the result as a new image which is posted on the bot accounts on Twitter and Mastodon. The images are also displayed on the website and can be downloaded from there.<br>
This self-hosted project is built and maintained using Ruby, Ruby on Rails and MySQL.

http://fortheloveofquote.com
