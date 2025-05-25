//CONSULTA 4

MATCH
  (:Country {name: 'Burma'})<-[:IS_PART_OF]-(:City)<-[:IS_LOCATED_IN]-
  (person:Person)<-[:HAS_MODERATOR]-(forum:Forum)-[:CONTAINER_OF]->
  (post:Post)-[:HAS_TAG]->(:Tag)-[:HAS_TYPE]->(:TagClass {name: 'MusicalArtist'})
RETURN
  forum.id,
  forum.title,
  forum.creationDate,
  person.id,
  count(DISTINCT post) AS postCount
ORDER BY
  postCount DESC,
  forum.id ASC
LIMIT 20

//Estrategia de optimización
//Materialización
MATCH
  (post:Post)-[:HAS_TAG]->(:Tag)-[:HAS_TYPE]->(tagclass:TagClass)
create (post)-[:BI4_forum_post_tagClass]->(tagclass)

//Consulta optimizada
MATCH
  (:Country {name: 'Burma'})<-[:IS_PART_OF]-(:City)<-[:IS_LOCATED_IN]-
  (person:Person)<-[:HAS_MODERATOR]-(forum:Forum)-[:CONTAINER_OF]->
  (post:Post)-[:BI4_post_tagClass]->(:TagClass{name: 'MusicalArtist'})
RETURN
  forum.id,
  forum.title,
  forum.creationDate,
  person.id,
  count(DISTINCT post) AS postCount
ORDER BY
  postCount DESC,
  forum.id ASC
LIMIT 20