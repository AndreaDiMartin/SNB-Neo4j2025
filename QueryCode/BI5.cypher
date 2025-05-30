//CONSULTA 5

MATCH
  (:Country {name: 'Belarus'})<-[:IS_PART_OF]-(:City)<-[:IS_LOCATED_IN]-
  (person:Person)<-[:HAS_MEMBER]-(forum:Forum)
WITH forum, count(person) AS numberOfMembers
ORDER BY numberOfMembers DESC, forum.id ASC
LIMIT 100
WITH collect(forum) AS popularForums
UNWIND popularForums AS forum
MATCH
  (forum)-[:HAS_MEMBER]->(person:Person)
OPTIONAL MATCH
  (person)<-[:HAS_CREATOR]-(post:Post)<-[:CONTAINER_OF]-(popularForum:Forum)
WHERE popularForum IN popularForums
RETURN
  person.id,
  person.firstName,
  person.lastName,
  person.creationDate,
  count(DISTINCT post) AS postCount
ORDER BY
  postCount DESC,
  person.id ASC
LIMIT 100

//Estrategia de optimización
//Materialización
MATCH (c:Country)<-[:IS_PART_OF]-(:City)<-[:IS_LOCATED_IN]-
  (person:Person)<-[:HAS_MEMBER]-(forum:Forum)
WITH c, forum, COUNT(person) AS nom
CREATE (c)<-[:BI5_country_forum{numberOfMembers:nom}]-(forum)

//Consulta modificada
MATCH
  (:Country {name: 'Belarus'})<-[r:BI5_country_forum]-(forum:Forum)
WITH forum, r.numberOfMembers AS nom
ORDER BY nom DESC, forum.id ASC
LIMIT 100
WITH collect(forum) AS popularForums
UNWIND popularForums AS forum
MATCH
  (forum)-[:HAS_MEMBER]->(person:Person)
OPTIONAL MATCH
  (person)<-[:HAS_CREATOR]-(post:Post)<-[:CONTAINER_OF]-(popularForum:Forum)
WHERE popularForum IN popularForums
WITH person, count(DISTINCT post) AS postCount
ORDER BY
  postCount DESC,
  person.id ASC
LIMIT 100
RETURN
  person.id,
  person.firstName,
  person.lastName,
  person.creationDate,
  postCount

