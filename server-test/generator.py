# -- coding: utf-8 --
import csv


class Generator(object):
    @staticmethod
    def generate_data(nb_artists=10, nb_albums=2, nb_songs=4):
        artist_filename = "artists.csv"
        song_filename = "songs.csv"
        with open(artist_filename, 'w') as f_a, open(song_filename, 'w') as f_s:
            writer_a = csv.writer(f_a, delimiter=',', lineterminator='\n')
            writer_a.writerow(["# Artist, Album 1, Album 2, ..."])
            writer_s = csv.writer(f_s, delimiter=',', lineterminator='\n')
            writer_s.writerow(["# Album, Song 1, Song 2, ..."])
            for i in range(1, nb_artists+1):
                artist_number = Generator.format_number(i, nb_artists)
                artist_name = 'Artist_{0}'.format(artist_number)
                row_a = [artist_name]
                for j in range(1, nb_albums+1):
                    album_number = Generator.format_number(j, nb_albums)
                    album_name = "Album_{0}_{1}".format(
                        album_number, artist_number
                    )
                    row_a.append(album_name)
                    row_s = [album_name]
                    for k in range(1, nb_songs+1):
                        song_number = Generator.format_number(k, nb_songs)
                        row_s.append("Song_{0}_{1}".format(song_number, album_name))
                    writer_s.writerow(row_s)
                writer_a.writerow(row_a)

    @staticmethod
    def format_number(pos, max_val):
        digit = len(str(max_val))
        return '{0:0{nb_digit}d}'.format(
            pos,
            nb_digit=digit
        )


if __name__ == "__main__":
    Generator.generate_data()
