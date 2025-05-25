//CONSULTA 19

MATCH
  (:TagClass {name: 'MusicalArtist'})<-[:HAS_TYPE]-(:Tag)<-[:HAS_TAG]-
  (forum1:Forum)-[:HAS_MEMBER]->(stranger:Person)
WITH DISTINCT stranger
MATCH
  (:TagClass {name: 'OfficeHolder'})<-[:HAS_TYPE]-(:Tag)<-[:HAS_TAG]-
  (forum2:Forum)-[:HAS_MEMBER]->(stranger)
WITH DISTINCT stranger
MATCH
  (person:Person)<-[:HAS_CREATOR]-(comment:Comment)-[:REPLY_OF*]->(message:Message)-[:HAS_CREATOR]->(stranger)
WHERE person.birthday > date("1989-01-01")
  AND person <> stranger
  AND NOT (person)-[:KNOWS]-(stranger)
  AND NOT (message)-[:REPLY_OF*]->(:Message)-[:HAS_CREATOR]->(stranger)
RETURN
  person.id,
  count(DISTINCT stranger) AS strangersCount,
  count(comment) AS interactionCount
ORDER BY
  interactionCount DESC,
  person.id ASC
LIMIT 100

//Estrategia de optimización
// Materializacion
MATCH (message:Message)-[:REPLY_OF*]->(post:Message) CREATE (message)-[:BI19_message]->(post)


//Consulta modificada
MATCH
  (:TagClass {name: 'MusicalArtist'})<-[:BI_forum_tagclass]-
  (forum1:Forum)-[:HAS_MEMBER]->(stranger:Person)
WITH DISTINCT stranger
MATCH
  (:TagClass {name: 'OfficeHolder'})<-[:BI_forum_tagclass]-
  (forum2:Forum)-[:HAS_MEMBER]->(stranger)
WITH DISTINCT stranger
MATCH
  (person:Person)<-[:HAS_CREATOR]-(comment:Comment)-[:BI19_message]->(message:Message)-[:HAS_CREATOR]->(stranger)
WHERE person.birthday > date("1989-01-01")
  AND person <> stranger
  AND NOT (person)-[:KNOWS]-(stranger)
  AND NOT (message)-[:BI19_message]->(:Message)-[:HAS_CREATOR]->(stranger)
WITH person, count(DISTINCT stranger) AS strangersCount, count(comment) AS interactionCount
ORDER BY
  interactionCount DESC,
  person.id ASC
LIMIT 100
RETURN
  person.id,
  strangersCount,
  interactionCount