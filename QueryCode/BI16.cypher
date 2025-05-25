//CONSULTA 16

MATCH
  (:Person {id: "8698"})-[:KNOWS*3..5]-(person:Person)
WITH DISTINCT person
MATCH
  (person)-[:IS_LOCATED_IN]->(:City)-[:IS_PART_OF]->(:Country {name: 'Pakistan'}),
  (person)<-[:HAS_CREATOR]-(message:Message)-[:HAS_TAG]->(:Tag)-[:HAS_TYPE]->
  (:TagClass {name: 'MusicalArtist'})
MATCH
  (message)-[:HAS_TAG]->(tag:Tag)
RETURN
  person.id,
  tag.name,
  count(DISTINCT message) AS messageCount
ORDER BY
  messageCount DESC,
  tag.name ASC,
  person.id ASC
LIMIT 100

//Estrategia de optimización
// MATERIALIZACION
MATCH
(message:Message)-[:HAS_TAG]->(:Tag)-[:HAS_TYPE]->(tagclass:TagClass)
create (message)-[:BI16_forum_post_tagClass]->(tagclass)

//Consulta modificada
MATCH
  (:Person {id: "8698"})-[:KNOWS*3..5]-(person:Person)
WITH DISTINCT person
MATCH
  (person)-[:IS_LOCATED_IN]->(:City)-[:IS_PART_OF]->(:Country {name: 'Pakistan'}),
  (person)<-[:HAS_CREATOR]-(message:Message)-[:BI4_tag_post_tagClass]->
  (:TagClass {name: 'MusicalArtist'})
MATCH
  (message)-[:HAS_TAG]->(tag:Tag)
RETURN
  person.id,
  tag.name,
  count(DISTINCT message) AS messageCount
ORDER BY
  messageCount DESC,
  tag.name ASC,
  person.id ASC
LIMIT 100