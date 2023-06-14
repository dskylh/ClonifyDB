-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Dec 25, 2022 at 09:30 PM
-- Server version: 10.4.27-MariaDB
-- PHP Version: 8.1.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `clonify`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `album_like_muzik` (IN `muzik` VARCHAR(255))   begin
    select album_isim, sanatci_isim
    from Muzikler
             inner join Album_Muzik on Muzikler.muzik_id = Album_Muzik.muzik_id
             inner join Albumler on Album_Muzik.album_id = Albumler.album_id
             inner join Sanatci_Album on Albumler.album_id = Sanatci_Album.album_id
             inner join Sanatcilar on Sanatci_Album.sanatci_id = Sanatcilar.sanatci_id
    WHERE Muzikler.muzik_isim LIKE concat('%', muzik, '%')
    ORDER BY album_isim;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `en_cok_dinlenen_sanatci` ()   begin
    select sanatci_isim, sum(dinleme_sayisi) as toplam_dinleme
    from Muzikler
             inner join Album_Muzik on Muzikler.muzik_id = Album_Muzik.muzik_id
             inner join Albumler on Album_Muzik.album_id = Albumler.album_id
             inner join Sanatci_Album on Albumler.album_id = Sanatci_Album.album_id
             inner join Sanatcilar on Sanatci_Album.sanatci_id = Sanatcilar.sanatci_id
    group by sanatci_isim
    order by toplam_dinleme desc;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `kullanici_playlistleri` (IN `k_adi` VARCHAR(255))   BEGIN
    select Kullanicilar.kullanici_adi, playlist_isim
    from Kullanicilar
             inner join Playlistler on Kullanicilar.kullanici_id = Playlistler.kullanici_id
    where Kullanicilar.kullanici_id = (select Kullanicilar.kullanici_id from Kullanicilar where kullanici_adi = k_adi);
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `muzik_album_sanatci` ()   BEGIN
    select muzik_isim, album_isim, sanatci_isim
    from Muzikler
             inner join Album_Muzik on Muzikler.muzik_id = Album_Muzik.muzik_id
             inner join Albumler on Album_Muzik.album_id = Albumler.album_id
             inner join Sanatci_Album on Albumler.album_id = Sanatci_Album.album_id
             inner join Sanatcilar on Sanatci_Album.sanatci_id = Sanatcilar.sanatci_id
    group by muzik_isim, album_isim, album_isim;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `muzik_dinlenme_araligi` (IN `dinleme_1` INT, IN `dinleme_2` INT)   begin
    declare temp int;

    if dinleme_1 > dinleme_2 then
        set temp = dinleme_1;
        set dinleme_1 = dinleme_2;
        set dinleme_2 = temp;
    end if;

    select muzik_isim, album_isim, sanatci_isim, dinleme_sayisi 
    from Muzikler
             inner join Album_Muzik on Muzikler.muzik_id = Album_Muzik.muzik_id
             inner join Albumler on Album_Muzik.album_id = Albumler.album_id
             inner join Sanatci_Album on Albumler.album_id = Sanatci_Album.album_id
             inner join Sanatcilar on Sanatci_Album.sanatci_id = Sanatcilar.sanatci_id
    where dinleme_sayisi between dinleme_1 and dinleme_2
    order by dinleme_sayisi desc;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `muzik_ekle` (IN `muzik` VARCHAR(255), IN `album` VARCHAR(255), IN `sanatci` VARCHAR(255), IN `tur` VARCHAR(255))   begin
    insert into Albumler (album_isim)
    select album
    where not exists(select 1 from Albumler where album_isim = album);

    insert into Sanatcilar(sanatci_isim)
    select sanatci
    where not exists(select 1 from Sanatcilar where sanatci_isim = sanatci);

    insert into Muzik_Turleri(muzik_tur_isim)
    select tur
    where not exists(select 1 from Muzik_Turleri where muzik_tur_isim = tur);

    insert into Muzikler (muzik_isim) values (muzik);

    set @albumId = (select album_id from Albumler where album_isim = album);
    set @turId = (select muzik_tur_id from Muzik_Turleri where muzik_tur_isim = tur);
    set @muzikId = (select muzik_id from Muzikler where muzik_isim = muzik);
    set @sanatciId = (select sanatci_id from Sanatcilar where sanatci_isim = sanatci);

    insert into Album_Muzik (album_id, muzik_id) values (@albumId, @muzikId);
    insert into Muzik_Tur(muzik_id, muzik_tur_id) values (@muzikId, @turId);
    insert into Sanatci_Album(sanatci_id, album_id) values (@sanatciId, @albumId);

end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `muzik_turu_dinleneme` ()   BEGIN
    select muzik_tur_isim, sum(dinleme_sayisi) as toplam_dinleme_sayisi
    from Muzik_Turleri
             inner join Muzik_Tur on Muzik_Turleri.muzik_tur_id = Muzik_Tur.muzik_tur_id
             inner join Muzikler on Muzik_Tur.muzik_id = Muzikler.muzik_id
    group by muzik_tur_isim
    order by toplam_dinleme_sayisi desc;


end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `playlist_muzik_sayisi` (IN `k_adi` VARCHAR(255))   begin
    select playlist_isim, count(Muzik_Playlist.muzik_id) as muzik_sayisi
    from Playlistler
             inner join Muzik_Playlist on Playlistler.playlist_id = Muzik_Playlist.playlist_id
             inner join Kullanicilar on Playlistler.kullanici_id = Kullanicilar.kullanici_id
    where k_adi = kullanici_adi
    group by playlist_isim
    order by muzik_sayisi;

end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sanatci_ortalamadan_yuksek_muzikler` (IN `sanatci` VARCHAR(255))   begin
    select Muzikler.muzik_isim, Muzikler.dinleme_sayisi
    from Sanatcilar
             inner join Sanatci_Album on Sanatcilar.sanatci_id = Sanatci_Album.sanatci_id
             inner join Albumler on Sanatci_Album.album_id = Albumler.album_id
             inner join Album_Muzik on Albumler.album_id = Album_Muzik.album_id
             inner join Muzikler on Album_Muzik.muzik_id = Muzikler.muzik_id
    where Sanatcilar.sanatci_isim = sanatci
      and Muzikler.dinleme_sayisi > (select AVG(dinleme_sayisi) from Muzikler)
    order by Muzikler.dinleme_sayisi desc;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `turlerine_gore_albumler` (IN `tur1` VARCHAR(255), IN `tur2` VARCHAR(255), IN `tur3` VARCHAR(255))   begin
    select album_isim, COUNT(Muzikler.muzik_id) AS 'song_count'
    from Albumler
    inner join Album_Muzik on Albumler.album_id = Album_Muzik.album_id
    inner join Muzikler on Album_Muzik.muzik_id = Muzikler.muzik_id
    inner join Muzik_Tur on Muzikler.muzik_id = Muzik_Tur.muzik_id
    inner join Muzik_Turleri on Muzik_Tur.muzik_tur_id = Muzik_Turleri.muzik_tur_id
    where Muzik_Turleri.muzik_tur_isim in (tur1, tur2, tur3)
    group by Albumler.album_isim
    order by song_count desc;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ulkeye_gore_gelir` (IN `ulke_isim` VARCHAR(255))   begin
    select ulke, sum(ucret) as gelir
    from Kullanicilar
             inner join Uyelik_Turleri on Kullanicilar.uyelik_tur = Uyelik_Turleri.uyelik_tur_id
    group by ulke
    having ulke = ulke_isim;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `uyeligi_bitmis_kullanicilar` ()   BEGIN
    SELECT kullanici_adi, timestampdiff(Day, curdate(), uyelik_bitis) as uyelik_gecen_zaman
    from Kullanicilar
    where timestampdiff(Day, curdate(), uyelik_bitis) < 0;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `uyelik_guncelle` (IN `kullaniciId` INT, IN `yeni_uyelik_id` INT)   BEGIN
    update Kullanicilar
    set uyelik_tur       = yeni_uyelik_id,
        uyelik_baslangic = NOW(),
        uyelik_bitis     = DATE_ADD(uyelik_baslangic, INTERVAL 1 MONTH)
    where kullanici_id = kullaniciId
      and TIMESTAMPDIFF(DAY, curdate(), uyelik_bitis) < 0;

END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `Albumler`
--

CREATE TABLE `Albumler` (
  `album_id` int(11) NOT NULL,
  `album_isim` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `Albumler`
--

INSERT INTO `Albumler` (`album_id`, `album_isim`) VALUES
(1, 'Divide'),
(2, 'A Night at the Opera'),
(3, '7'),
(4, 'Supernatural'),
(5, 'Appetite for Destruction'),
(6, 'Led Zeppelin IV'),
(7, 'Purpose'),
(8, 'Anti'),
(9, 'Uptown Special'),
(10, 'Let It Be'),
(11, 'Second Helping'),
(12, 'Hotel California'),
(13, 'Imagine'),
(14, 'x (Multiply)'),
(15, 'Purple Rain'),
(16, 'Thriller'),
(17, 'The Bodyguard'),
(18, 'Sweet Dreams (Are Made of This)'),
(19, 'From Mars To Sirius'),
(20, 'Magma'),
(21, 'Images and Words');

--
-- Triggers `Albumler`
--
DELIMITER $$
CREATE TRIGGER `albumler_delete_trigger` AFTER DELETE ON `Albumler` FOR EACH ROW BEGIN
    INSERT INTO Albumler_Deleted(album_id, album_isim)
    VALUES (OLD.album_id, OLD.album_isim);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `Albumler_Deleted`
--

CREATE TABLE `Albumler_Deleted` (
  `album_id` int(11) DEFAULT NULL,
  `album_isim` varchar(255) DEFAULT NULL,
  `silinme_tarihi` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `Album_Muzik`
--

CREATE TABLE `Album_Muzik` (
  `album_id` int(11) DEFAULT NULL,
  `muzik_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `Album_Muzik`
--

INSERT INTO `Album_Muzik` (`album_id`, `muzik_id`) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(1, 7),
(7, 8),
(8, 9),
(9, 10),
(10, 11),
(11, 12),
(12, 13),
(13, 14),
(14, 15),
(15, 16),
(16, 17),
(17, 18),
(18, 19),
(19, 21),
(20, 22),
(21, 23);

-- --------------------------------------------------------

--
-- Table structure for table `Kullanicilar`
--

CREATE TABLE `Kullanicilar` (
  `kullanici_id` int(11) NOT NULL,
  `kullanici_adi` varchar(255) NOT NULL,
  `sifre` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `ulke` varchar(255) DEFAULT NULL,
  `uyelik_baslangic` datetime NOT NULL,
  `uyelik_bitis` datetime DEFAULT NULL,
  `uyelik_tur` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `Kullanicilar`
--

INSERT INTO `Kullanicilar` (`kullanici_id`, `kullanici_adi`, `sifre`, `email`, `ulke`, `uyelik_baslangic`, `uyelik_bitis`, `uyelik_tur`) VALUES
(1, 'mehmet', 'sifre123', 'mehmet@example.com', 'Turkiye', '2022-12-24 16:01:33', '2023-01-24 16:01:33', 2),
(2, 'zeynep', 'sifre456', 'zeynep@example.com', 'Turkiye', '2022-12-24 21:33:57', '2023-01-24 21:33:57', 1),
(3, 'ahmet', 'sifre789', 'ahmet@example.com', 'Turkiye', '2022-12-24 21:33:57', '2023-01-24 21:33:57', 1),
(4, 'deniz', 'sifre123', 'deniz@example.com', 'Turkiye', '2022-12-24 21:33:57', '2023-01-24 21:33:57', 1),
(5, 'emre', 'sifre456', 'emre@example.com', 'Turkiye', '2022-12-24 21:33:57', '2023-01-24 21:33:57', 1),
(6, 'sarah', 'sifre123', 'sarah@example.com', 'USA', '2022-12-24 21:33:31', '2023-01-24 21:33:31', 1),
(7, 'peter', 'sifre456', 'peter@example.com', 'Germany', '2022-12-24 21:33:31', '2023-01-24 21:33:31', 1),
(8, 'john', 'sifre789', 'john@example.com', 'UK', '2022-12-24 21:33:31', '2023-01-24 21:33:31', 1),
(9, 'lisa', 'sifre123', 'lisa@example.com', 'USA', '2022-12-24 21:33:31', '2023-01-24 21:33:31', 1),
(10, 'michael', 'sifre456', 'michael@example.com', 'Australia', '2022-12-24 21:33:31', '2023-01-24 21:33:31', 1),
(11, 'david', 'sifre123', 'david@example.com', 'USA', '2022-12-24 21:33:31', '2023-01-24 21:33:31', 1),
(12, 'maria', 'sifre456', 'maria@example.com', 'Spain', '2022-12-24 21:33:31', '2023-01-24 21:33:31', 1),
(13, 'chris', 'sifre789', 'chris@example.com', 'USA', '2022-12-24 21:33:31', '2023-01-24 21:33:31', 1),
(14, 'olivia', 'sifre123', 'olivia@example.com', 'UK', '2022-12-24 21:33:31', '2023-01-24 21:33:31', 1),
(15, 'tugba', 'sifre123', 'tugba@example.com', 'Turkiye', '2022-12-24 21:33:31', '2023-01-24 21:33:31', 1),
(16, 'burak', 'sifre456', 'burak@example.com', 'Turkiye', '2022-12-24 21:33:31', '2023-01-24 21:33:31', 1),
(17, 'hande', 'sifre789', 'hande@example.com', 'Turkiye', '2022-12-24 21:33:31', '2023-01-24 21:33:31', 1),
(21, 'taha', '1234', 'taha@example.com', 'Turkiye', '2022-12-24 21:33:31', '2022-12-21 20:50:34', 1);

--
-- Triggers `Kullanicilar`
--
DELIMITER $$
CREATE TRIGGER `delete_user_playlists` AFTER DELETE ON `Kullanicilar` FOR EACH ROW BEGIN
    delete from Playlistler where Playlistler.kullanici_id = OLD.kullanici_id;
    delete
    from Muzik_Playlist
    where playlist_id in (select playlist_id from Playlistler where kullanici_id = OLD.kullanici_id);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `kullanicilar_delete_trigger` AFTER DELETE ON `Kullanicilar` FOR EACH ROW begin
    insert into Kullanicilar_Deleted (kullanici_id, kullanici_adi, sifre, email, ulke, uyelik_baslangic, uyelik_bitis,
                                      uyelik_tur)
    VALUES (OLD.kullanici_id, OLD.kullanici_adi, OLD.sifre, OLD.email, OLD.ulke, OLD.uyelik_baslangic, OLD.uyelik_bitis,
            OLD.uyelik_tur);
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `Kullanicilar_Deleted`
--

CREATE TABLE `Kullanicilar_Deleted` (
  `kullanici_id` int(11) NOT NULL,
  `kullanici_adi` varchar(255) NOT NULL,
  `sifre` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `ulke` varchar(255) DEFAULT NULL,
  `uyelik_baslangic` datetime NOT NULL,
  `uyelik_bitis` datetime DEFAULT NULL,
  `uyelik_tur` int(11) NOT NULL,
  `silinme_tarihi` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `Kullanicilar_Deleted`
--

INSERT INTO `Kullanicilar_Deleted` (`kullanici_id`, `kullanici_adi`, `sifre`, `email`, `ulke`, `uyelik_baslangic`, `uyelik_bitis`, `uyelik_tur`, `silinme_tarihi`) VALUES
(18, 'taha', '1234', 'taha@example.com', 'Turkiye', '2022-12-24 20:27:26', NULL, 2, '2022-12-24 20:27:48');

-- --------------------------------------------------------

--
-- Table structure for table `Muzikler`
--

CREATE TABLE `Muzikler` (
  `muzik_id` int(11) NOT NULL,
  `muzik_isim` varchar(255) NOT NULL,
  `dinleme_sayisi` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `Muzikler`
--

INSERT INTO `Muzikler` (`muzik_id`, `muzik_isim`, `dinleme_sayisi`) VALUES
(1, 'Shape of You', 1000),
(2, 'Bohemian Rhapsody', 500),
(3, 'Old Town Road', 750),
(4, 'Smooth', 250),
(5, 'Sweet Child o\' Mine', 300),
(6, 'Stairway to Heaven', 200),
(7, 'Happier', 400),
(8, 'Sorry', 500),
(9, 'Love on the Brain', 200),
(10, 'Uptown Funk', 750),
(11, 'Let it Be', 250),
(12, 'Sweet Home Alabama', 350),
(13, 'Hotel California', 450),
(14, 'Imagine', 300),
(15, 'Thinking Out Loud', 500),
(16, 'Purple Rain', 400),
(17, 'Billie Jean', 600),
(18, 'I Will Always Love You', 200),
(19, 'Sweet Dreams (Are Made of This)', 250),
(20, 'Under the Bridge', 350),
(21, 'Flying Whales', 20),
(22, 'Stranded', 10),
(23, 'Pull me Under', NULL);

--
-- Triggers `Muzikler`
--
DELIMITER $$
CREATE TRIGGER `muzikler_update_trigger` AFTER UPDATE ON `Muzikler` FOR EACH ROW BEGIN
    insert into Muzikler_Updated(muzik_id, old_dinleme_sayisi, new_dinleme_sayisi)
    VALUES (OLD.muzik_id, OLD.dinleme_sayisi, NEW.dinleme_sayisi);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `Muzikler_Updated`
--

CREATE TABLE `Muzikler_Updated` (
  `log_id` int(11) NOT NULL,
  `muzik_id` int(11) NOT NULL,
  `old_dinleme_sayisi` int(11) DEFAULT NULL,
  `new_dinleme_sayisi` int(11) NOT NULL,
  `guncelleme_tarihi` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `Muzikler_Updated`
--

INSERT INTO `Muzikler_Updated` (`log_id`, `muzik_id`, `old_dinleme_sayisi`, `new_dinleme_sayisi`, `guncelleme_tarihi`) VALUES
(1, 21, NULL, 10, '2022-12-24 18:29:21'),
(2, 22, NULL, 10, '2022-12-24 18:29:21'),
(3, 21, 10, 20, '2022-12-24 18:29:25');

-- --------------------------------------------------------

--
-- Table structure for table `Muzik_Playlist`
--

CREATE TABLE `Muzik_Playlist` (
  `muzik_id` int(11) DEFAULT NULL,
  `playlist_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `Muzik_Playlist`
--

INSERT INTO `Muzik_Playlist` (`muzik_id`, `playlist_id`) VALUES
(1, 1),
(2, 1),
(3, 1),
(1, 2),
(3, 2),
(4, 2),
(3, 3),
(11, 3),
(12, 3),
(2, 4),
(5, 4),
(6, 4),
(1, 5),
(2, 5),
(3, 5),
(1, 6),
(3, 6),
(4, 6),
(2, 7),
(5, 7),
(6, 7),
(3, 8),
(11, 8),
(12, 8),
(3, 9),
(11, 9),
(12, 9),
(2, 10),
(5, 10),
(6, 10),
(1, 11),
(3, 11),
(4, 11),
(2, 12),
(5, 12),
(6, 12),
(2, 13),
(5, 13),
(6, 13),
(2, 14),
(5, 14),
(6, 14),
(4, 15),
(11, 15),
(13, 15),
(4, 16),
(5, 16),
(6, 16),
(9, 17),
(8, 17),
(7, 17),
(3, 18),
(20, 18),
(19, 18),
(3, 19),
(7, 19),
(4, 19),
(4, 20),
(9, 20),
(10, 20),
(1, 21),
(3, 21),
(4, 21),
(4, 22),
(5, 22),
(6, 22),
(3, 23),
(11, 23),
(12, 23),
(2, 24),
(5, 24),
(6, 24),
(21, 1);

--
-- Triggers `Muzik_Playlist`
--
DELIMITER $$
CREATE TRIGGER `dineleme_sayisi_guncelle` AFTER INSERT ON `Muzik_Playlist` FOR EACH ROW BEGIN
    update Muzikler
    set dinleme_sayisi = dinleme_sayisi + 10
    where muzik_id = NEW.muzik_id;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `Muzik_Tur`
--

CREATE TABLE `Muzik_Tur` (
  `muzik_id` int(11) DEFAULT NULL,
  `muzik_tur_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `Muzik_Tur`
--

INSERT INTO `Muzik_Tur` (`muzik_id`, `muzik_tur_id`) VALUES
(1, 1),
(2, 2),
(3, 3),
(3, 4),
(4, 5),
(4, 6),
(5, 2),
(6, 2),
(7, 1),
(8, 1),
(9, 6),
(10, 1),
(10, 7),
(11, 2),
(12, 2),
(12, 4),
(13, 2),
(14, 1),
(15, 1),
(16, 2),
(16, 1),
(17, 1),
(17, 6),
(18, 1),
(18, 6),
(19, 1),
(19, 6),
(20, 1),
(20, 8),
(NULL, 13),
(22, 13),
(23, 13);

-- --------------------------------------------------------

--
-- Table structure for table `Muzik_Turleri`
--

CREATE TABLE `Muzik_Turleri` (
  `muzik_tur_id` int(11) NOT NULL,
  `muzik_tur_isim` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `Muzik_Turleri`
--

INSERT INTO `Muzik_Turleri` (`muzik_tur_id`, `muzik_tur_isim`) VALUES
(1, 'Pop'),
(2, 'Rock'),
(3, 'Hip hop'),
(4, 'Country'),
(5, 'Electronic'),
(6, 'R&B'),
(7, 'Jazz'),
(8, 'Blues'),
(9, 'Classical'),
(10, 'Folk'),
(11, 'Latin'),
(12, 'World'),
(13, 'Metal'),
(14, 'Punk'),
(15, 'Alternative');

-- --------------------------------------------------------

--
-- Table structure for table `Playlistler`
--

CREATE TABLE `Playlistler` (
  `playlist_id` int(11) NOT NULL,
  `playlist_isim` varchar(255) NOT NULL,
  `kullanici_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `Playlistler`
--

INSERT INTO `Playlistler` (`playlist_id`, `playlist_isim`, `kullanici_id`) VALUES
(1, 'Favori Sarkilarim', 1),
(2, 'Workout Playlist', 7),
(3, 'Road Trip Mix', 12),
(4, 'Chillout Sarkilar', 17),
(5, 'Sarkilar', 3),
(6, 'Party Time', 3),
(7, 'Gece Melodileri', 5),
(8, 'Summertime Bliss', 11),
(9, 'Road Trip Anthems', 14),
(10, 'Rainy Day Relaxation', 7),
(11, 'Gym Muzikleri', 9),
(12, 'Chillout Vibes', 5),
(13, 'Dinner Party Jams', 13),
(14, 'Indie Essentials', 14),
(15, 'Chillout Vibes', 2),
(16, 'Dinner Party Jams', 4),
(17, 'Indie Essentials', 6),
(18, 'Discover New Music', 8),
(19, '80 Retro Hits', 6),
(20, '90 Nostalgia', 5),
(21, '00 Throwback', 8),
(22, 'Fresh Hip Hop', 15),
(23, 'Old School Rap', 7),
(24, 'Pop Power Playlist', 10),
(25, 'Rock n Roll Legends', 5),
(26, 'Country Classics', 12),
(27, 'Jazz Classics', 16);

--
-- Triggers `Playlistler`
--
DELIMITER $$
CREATE TRIGGER `playlist_kontrol` AFTER INSERT ON `Playlistler` FOR EACH ROW BEGIN
    IF (select uyelik_tur from Kullanicilar where kullanici_id = NEW.kullanici_id) = 1 THEN
        IF (select count(*) from Playlistler where kullanici_id = NEW.kullanici_id) > 5 THEN
            delete from Playlistler where playlist_id = NEW.playlist_id;
        END IF;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `Podcastler`
--

CREATE TABLE `Podcastler` (
  `podcast_id` int(11) NOT NULL,
  `podcast_isim` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `Podcastler`
--

INSERT INTO `Podcastler` (`podcast_id`, `podcast_isim`) VALUES
(1, 'The Daily'),
(2, 'Radiolab'),
(3, 'This American Life'),
(4, 'Serial'),
(5, 'The Joe Rogan Experience'),
(6, 'The Tim Ferriss Show'),
(7, 'The Moth'),
(8, 'The Ben Shapiro Show'),
(9, 'TED Radio Hour'),
(10, ' Freakonomics Radio'),
(11, 'The Bill Simmons Podcast'),
(12, 'My Favorite Murder'),
(13, 'Stuff You Should Know'),
(14, 'Revisionist History'),
(15, 'How I Built This');

-- --------------------------------------------------------

--
-- Table structure for table `Sanatcilar`
--

CREATE TABLE `Sanatcilar` (
  `sanatci_id` int(11) NOT NULL,
  `sanatci_isim` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `Sanatcilar`
--

INSERT INTO `Sanatcilar` (`sanatci_id`, `sanatci_isim`) VALUES
(1, 'The Beatles'),
(2, 'Lynyrd Skynyrd'),
(3, 'The Eagles'),
(4, 'John Lennon'),
(5, 'Ed Sheeran'),
(6, 'Prince'),
(7, 'Michael Jackson'),
(8, 'Whitney Houston'),
(9, 'Eurythmics'),
(11, 'Queen'),
(12, 'Lil Nas X'),
(13, 'Santana'),
(14, 'Guns N Roses'),
(15, 'Led Zeppelin'),
(16, 'Justin Bieber'),
(17, 'Rihanna'),
(18, 'Mark Ronson'),
(19, 'Bruno Mars'),
(20, 'Michael Barbaro'),
(21, 'Jad Abumrad'),
(22, 'Robert Krulwich'),
(23, 'Ira Glass'),
(24, 'Sarah Koenig'),
(25, 'Joe Rogan'),
(26, 'Tim Ferriss'),
(27, 'Catherine Burns'),
(28, 'Ben Shapiro'),
(29, 'Guy Raz'),
(30, 'Stephen Dubner'),
(31, 'Bill Simmons'),
(32, 'Karen Kilgariff'),
(33, 'Georgia Hardstark'),
(34, 'Chuck Bryant'),
(35, 'Josh Clark'),
(36, 'Malcolm Gladwell'),
(37, 'Guy Raz'),
(38, 'Gojira'),
(39, 'Dream Theater');

--
-- Triggers `Sanatcilar`
--
DELIMITER $$
CREATE TRIGGER `sanatcilar_delete_trigger` AFTER DELETE ON `Sanatcilar` FOR EACH ROW BEGIN
    insert into Sanatcilar_Deleted(sanatci_id, sanatci_isim)
    values (OLD.sanatci_id, OLD.sanatci_isim);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `Sanatcilar_Deleted`
--

CREATE TABLE `Sanatcilar_Deleted` (
  `sanatci_id` int(11) DEFAULT NULL,
  `sanatci_isim` varchar(255) DEFAULT NULL,
  `silinme_tarihi` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `Sanatci_Album`
--

CREATE TABLE `Sanatci_Album` (
  `sanatci_id` int(11) DEFAULT NULL,
  `album_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `Sanatci_Album`
--

INSERT INTO `Sanatci_Album` (`sanatci_id`, `album_id`) VALUES
(1, 10),
(2, 11),
(3, 12),
(4, 13),
(5, 14),
(6, 15),
(7, 16),
(8, 17),
(9, 18),
(5, 1),
(12, 3),
(13, 4),
(14, 5),
(15, 6),
(16, 7),
(17, 8),
(18, 9),
(18, 9),
(19, 9),
(38, 19),
(38, 20),
(39, 21);

-- --------------------------------------------------------

--
-- Table structure for table `Sanatci_Podcast`
--

CREATE TABLE `Sanatci_Podcast` (
  `sanatci_id` int(11) DEFAULT NULL,
  `podcast_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `Sanatci_Podcast`
--

INSERT INTO `Sanatci_Podcast` (`sanatci_id`, `podcast_id`) VALUES
(20, 1),
(21, 2),
(22, 2),
(23, 3),
(24, 4),
(25, 5),
(26, 6),
(27, 7),
(28, 8),
(29, 9),
(30, 10),
(31, 11),
(32, 12),
(33, 12),
(34, 13),
(35, 13),
(36, 14),
(37, 15);

-- --------------------------------------------------------

--
-- Table structure for table `Uyelik_Turleri`
--

CREATE TABLE `Uyelik_Turleri` (
  `uyelik_tur_id` int(11) NOT NULL,
  `uyelik_tur_ad` varchar(255) NOT NULL,
  `ucret` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `Uyelik_Turleri`
--

INSERT INTO `Uyelik_Turleri` (`uyelik_tur_id`, `uyelik_tur_ad`, `ucret`) VALUES
(1, 'Ucretsiz', 0),
(2, 'Premium', 20),
(3, 'Aile', 50),
(4, 'Duo', 35),
(5, 'Ogrenci', 9);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `Albumler`
--
ALTER TABLE `Albumler`
  ADD PRIMARY KEY (`album_id`);

--
-- Indexes for table `Album_Muzik`
--
ALTER TABLE `Album_Muzik`
  ADD KEY `FK_Album_Muzik_album_id` (`album_id`),
  ADD KEY `FK_Album_Muzik_muzik_id` (`muzik_id`);

--
-- Indexes for table `Kullanicilar`
--
ALTER TABLE `Kullanicilar`
  ADD PRIMARY KEY (`kullanici_id`),
  ADD KEY `FK_kullanici_uyelik` (`uyelik_tur`);

--
-- Indexes for table `Kullanicilar_Deleted`
--
ALTER TABLE `Kullanicilar_Deleted`
  ADD PRIMARY KEY (`kullanici_id`);

--
-- Indexes for table `Muzikler`
--
ALTER TABLE `Muzikler`
  ADD PRIMARY KEY (`muzik_id`);

--
-- Indexes for table `Muzikler_Updated`
--
ALTER TABLE `Muzikler_Updated`
  ADD PRIMARY KEY (`log_id`);

--
-- Indexes for table `Muzik_Playlist`
--
ALTER TABLE `Muzik_Playlist`
  ADD KEY `FK_Muzik_Playlist_muzik_id` (`muzik_id`),
  ADD KEY `FK_Muzik_Tur_playlist_id` (`playlist_id`);

--
-- Indexes for table `Muzik_Tur`
--
ALTER TABLE `Muzik_Tur`
  ADD KEY `FK_Muzik_Tur_muzik_id` (`muzik_id`),
  ADD KEY `FK_Muzik_Tur_muzik_tur_id` (`muzik_tur_id`);

--
-- Indexes for table `Muzik_Turleri`
--
ALTER TABLE `Muzik_Turleri`
  ADD PRIMARY KEY (`muzik_tur_id`);

--
-- Indexes for table `Playlistler`
--
ALTER TABLE `Playlistler`
  ADD PRIMARY KEY (`playlist_id`),
  ADD KEY `FK_kullanici_playlist` (`kullanici_id`);

--
-- Indexes for table `Podcastler`
--
ALTER TABLE `Podcastler`
  ADD PRIMARY KEY (`podcast_id`);

--
-- Indexes for table `Sanatcilar`
--
ALTER TABLE `Sanatcilar`
  ADD PRIMARY KEY (`sanatci_id`);

--
-- Indexes for table `Sanatci_Album`
--
ALTER TABLE `Sanatci_Album`
  ADD KEY `FK_Sanatci_Album_sanatci_id` (`sanatci_id`),
  ADD KEY `FK_Sanatci_Album_album_id` (`album_id`);

--
-- Indexes for table `Sanatci_Podcast`
--
ALTER TABLE `Sanatci_Podcast`
  ADD KEY `FK_Sanatci_Podcast_sanatci_id` (`sanatci_id`),
  ADD KEY `FK_Sanatci_Podcast_podcast_id` (`podcast_id`);

--
-- Indexes for table `Uyelik_Turleri`
--
ALTER TABLE `Uyelik_Turleri`
  ADD PRIMARY KEY (`uyelik_tur_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `Albumler`
--
ALTER TABLE `Albumler`
  MODIFY `album_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT for table `Kullanicilar`
--
ALTER TABLE `Kullanicilar`
  MODIFY `kullanici_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT for table `Kullanicilar_Deleted`
--
ALTER TABLE `Kullanicilar_Deleted`
  MODIFY `kullanici_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `Muzikler`
--
ALTER TABLE `Muzikler`
  MODIFY `muzik_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- AUTO_INCREMENT for table `Muzikler_Updated`
--
ALTER TABLE `Muzikler_Updated`
  MODIFY `log_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `Muzik_Turleri`
--
ALTER TABLE `Muzik_Turleri`
  MODIFY `muzik_tur_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `Playlistler`
--
ALTER TABLE `Playlistler`
  MODIFY `playlist_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=28;

--
-- AUTO_INCREMENT for table `Podcastler`
--
ALTER TABLE `Podcastler`
  MODIFY `podcast_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `Sanatcilar`
--
ALTER TABLE `Sanatcilar`
  MODIFY `sanatci_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=40;

--
-- AUTO_INCREMENT for table `Uyelik_Turleri`
--
ALTER TABLE `Uyelik_Turleri`
  MODIFY `uyelik_tur_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `Album_Muzik`
--
ALTER TABLE `Album_Muzik`
  ADD CONSTRAINT `FK_Album_Muzik_album_id` FOREIGN KEY (`album_id`) REFERENCES `Albumler` (`album_id`),
  ADD CONSTRAINT `FK_Album_Muzik_muzik_id` FOREIGN KEY (`muzik_id`) REFERENCES `Muzikler` (`muzik_id`);

--
-- Constraints for table `Kullanicilar`
--
ALTER TABLE `Kullanicilar`
  ADD CONSTRAINT `FK_kullanici_uyelik` FOREIGN KEY (`uyelik_tur`) REFERENCES `Uyelik_Turleri` (`uyelik_tur_id`);

--
-- Constraints for table `Muzik_Playlist`
--
ALTER TABLE `Muzik_Playlist`
  ADD CONSTRAINT `FK_Muzik_Playlist_muzik_id` FOREIGN KEY (`muzik_id`) REFERENCES `Muzikler` (`muzik_id`),
  ADD CONSTRAINT `FK_Muzik_Tur_playlist_id` FOREIGN KEY (`playlist_id`) REFERENCES `Playlistler` (`playlist_id`);

--
-- Constraints for table `Muzik_Tur`
--
ALTER TABLE `Muzik_Tur`
  ADD CONSTRAINT `FK_Muzik_Tur_muzik_id` FOREIGN KEY (`muzik_id`) REFERENCES `Muzikler` (`muzik_id`),
  ADD CONSTRAINT `FK_Muzik_Tur_muzik_tur_id` FOREIGN KEY (`muzik_tur_id`) REFERENCES `Muzik_Turleri` (`muzik_tur_id`);

--
-- Constraints for table `Playlistler`
--
ALTER TABLE `Playlistler`
  ADD CONSTRAINT `FK_kullanici_playlist` FOREIGN KEY (`kullanici_id`) REFERENCES `Kullanicilar` (`kullanici_id`);

--
-- Constraints for table `Sanatci_Album`
--
ALTER TABLE `Sanatci_Album`
  ADD CONSTRAINT `FK_Sanatci_Album_album_id` FOREIGN KEY (`album_id`) REFERENCES `Albumler` (`album_id`),
  ADD CONSTRAINT `FK_Sanatci_Album_sanatci_id` FOREIGN KEY (`sanatci_id`) REFERENCES `Sanatcilar` (`sanatci_id`);

--
-- Constraints for table `Sanatci_Podcast`
--
ALTER TABLE `Sanatci_Podcast`
  ADD CONSTRAINT `FK_Sanatci_Podcast_podcast_id` FOREIGN KEY (`podcast_id`) REFERENCES `Podcastler` (`podcast_id`),
  ADD CONSTRAINT `FK_Sanatci_Podcast_sanatci_id` FOREIGN KEY (`sanatci_id`) REFERENCES `Sanatcilar` (`sanatci_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
