FROM ubuntu:latest

# Määritetään oletushakemisto, johon tiedostot tallennetaan
WORKDIR /ladatut

# Päivitetään järjestelmä ja asennetaan tarvittavat paketit
RUN apt update
RUN apt install curl -y
RUN apt install python-is-python3 -y

# Ladataan yt-dlp ja annetaan sille suoritusoikeudet
RUN curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp && \
chmod a+rx /usr/local/bin/yt-dlp
RUN LC_ALL=C.UTF-8
RUN apt-get update && apt-get install -y ffmpeg
# Määritetään volume, jotta ladatut tiedostot tallennetaan pysyvästi
# Ei pakollinen, koska docker-compose.ymlissä on volumet
VOLUME /ladatut

# Oletuksena käynnistetään bash ja odotetaan käyttäjän syötettä:
# silmukalla while true; "do .. done" silmukalla kyselee videoita
# Pitä kontti auki ilman silmukkaa, Jos haluat vain, että kontti pysyy päällä myös latauksen jälkeen ilman jatkuvaa latauspyyntöä, lisää yksinkertaisesti tail -f /dev/null:
# ENTRYPOINT ["bash", "-c", "echo 'Anna videon URL:'; read website; /usr/local/bin/yt-dlp $website; tail -f /dev/null"]
#ENTRYPOINT ["bash", "-c", "while true; do echo 'Anna videon URL:'; read website; /usr/local/bin/yt-dlp $website; done"]
#huomaa if lause, että exit komennolla loppuu kontin elämä
#ENTRYPOINT ["bash", "-c", "while true; do echo 'Anna videon URL:'; read website; if [[ \"$website\" == \"exit\" ]]; then echo 'Kontti sammuu...'; break; fi; /usr/local/bin/yt-dlp \"$website\"; done"]
# Oletuksena käynnistetään bash ja odotetaan käyttäjän syötettä
#lisätty ffmegin lataus mp4 videoille ja ääniraita mukaan
ENTRYPOINT ["bash", "-c", "while true; do \
    echo 'Anna videon URL (kirjoita exit lopettaaksesi):'; \
    read website; \
    if [[ \"$website\" == \"exit\" ]]; then \
        echo 'Kontti sammuu...'; \
        break; \
    fi; \
    echo 'Ladataan video MP4-muodossa...'; \
    /usr/local/bin/yt-dlp -f 'bv*[ext=mp4]+ba[ext=m4a]/b[ext=mp4]' --merge-output-format mp4 \"$website\"; \
    echo 'Ladataan ääni erillisenä MP3-tiedostona...'; \
    /usr/local/bin/yt-dlp -f 'ba' --extract-audio --audio-format mp3 \"$website\"; \
    echo 'Ladataan video WEBM-muodossa... tai jossakin hyvassa'; \
    /usr/local/bin/yt-dlp \"$website\"; \
done"]
# Tee Docker-image näin:
#docker build -t lataayoutube .
#tällöin muodostuu docker image nimeltä "lataayoutube" HUOM. nimi. se on docker composessa
#avaa kontti näin:
#docker-compose run --rm youtube
#sulje kontti "exit" silloin kun kontti kysyy videon URL


# ship-it-580