//CONSULTA 13

MATCH (:Country {name: 'Burma'})<-[:IS_LOCATED_IN]-(message:Message)
OPTIONAL MATCH (message)-[:HAS_TAG]->(tag:Tag)
WITH
  message.creationDate.year   AS year,
  message.creationDate.month AS month,
  message,
  tag
WITH year, month, count(message) AS popularity, tag
ORDER BY popularity DESC, tag.name ASC
WITH
  year,
  month,
  collect([tag.name, popularity]) AS popularTags
WITH
  year,
  month,
  [popularTag IN popularTags WHERE popularTag[0] IS NOT NULL] AS popularTags
RETURN
  year,
  month,
  popularTags[0..5] AS topPopularTags
ORDER BY
  year DESC,
  month ASC
LIMIT 100

//Estrategia de optimización
// NO SE HA CONSEGIDO OPTIMIZAR LA CONSULTA