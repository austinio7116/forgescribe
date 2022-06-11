#to create the image
docker build -t nmtforge .

#to run the container
docker run -it -v C:\path\to\forgescribe:/NMT -v C:\path\to\forge\cardsfolder:/cardsfolder nmtforge bash

