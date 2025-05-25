//CONSULTA 2

MATCH
  (country:Country)<-[:IS_PART_OF]-(:City)<-[:IS_LOCATED_IN]-(person:Person)
  <-[:HAS_CREATOR]-(message:Message)-[:HAS_TAG]->(tag:Tag)
WHERE message.creationDate >= datetime('2009-12-31T23:00:00') //Usar igualdad
  AND message.creationDate <= datetime('2010-11-07T23:00:00') //PROBAR CON EL INDICE
  AND (country.name = 'Ethiopia' OR country.name = 'Belarus')
WITH
  country.name AS countryName,
  message.creationDate.month AS month,
  person.gender AS gender,
  floor(duration.between(person.birthday,date("2013-01-01")).months/12.0 / 5.0) AS ageGroup,
  tag.name AS tagName,
  message
WITH
  countryName, month, gender, ageGroup, tagName, count(message) AS messageCount
WHERE messageCount > 100
RETURN
  countryName,
  month,
  gender,
  ageGroup,
  tagName,
  messageCount
ORDER BY
  messageCount DESC,
  tagName ASC,
  ageGroup ASC,
  gender ASC,
  month ASC,
  countryName ASC
LIMIT 100

//Estrategia de optimización
//Materialización 1
MATCH
  (country:Country)<-[:IS_PART_OF]-(:City)<-[:IS_LOCATED_IN]-(person:Person)
CREATE (country)<-[:BI_country_person]-(person)

//Consulta con materialización 1
MATCH
  (country:Country)<-[:BI_country_person]-(person:Person)
  <-[:hasCreator]-(message:Message)-[:HAS_TAG]->(tag:Tag)
WHERE message.creationDate >= datetime('2009-12-31T23:00:00')
  AND message.creationDate <= datetime('2010-11-07T23:00:00')
  AND (country.name = 'Ethiopia' OR country.name = 'Belarus')
WITH
  country.name AS countryName,
  message.creationDate.month AS month,
  person.gender AS gender,
  floor(duration.between(person.birthday,date("2013-01-01")).months/12.0 / 5.0) AS ageGroup,
  tag.name AS tagName,
  message
WITH
  countryName, month, gender, ageGroup, tagName, count(message) AS messageCount
WHERE messageCount > 100
WITH countryName, month, gender, ageGroup, tagName, messageCount
ORDER BY
  messageCount DESC,
  tagName ASC,
  ageGroup ASC,
  gender ASC,
  month ASC,
  countryName ASC
LIMIT 100
RETURN
  countryName,
  month,
  gender,
  ageGroup,
  tagName,
  messageCount
