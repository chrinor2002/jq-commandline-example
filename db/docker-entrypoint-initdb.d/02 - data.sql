DELIMITER //

CREATE PROCEDURE load_mock_article_data()
BEGIN

DECLARE v_max INT unsigned default 1000;
DECLARE v_counter INT unsigned DEFAULT 0;

  TRUNCATE TABLE `articles`;
  START TRANSACTION;
  WHILE v_counter < v_max do
    INSERT INTO `articles`
    (`uuid`,
    `title`,
    `article`)
    VALUES
    (UUID(),
    lipsum(5, 2, 0),
    lipsum(500, 100, 0));

    SET v_counter=v_counter + 1;
  END WHILE;
  COMMIT;
END;
//
DELIMITER ;

CALL load_mock_article_data();
