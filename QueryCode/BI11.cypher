//CONSULTA 11

WITH ['also', 'Pope', 'that', 'James', 'Henry', 'one', 'Green'] AS blacklist
MATCH
  (country:Country {name: 'Germany'})<-[:IS_PART_OF]-(:City)<-[:IS_LOCATED_IN]-
  (person:Person)<-[:HAS_CREATOR]-(reply:Comment)-[:REPLY_OF]->(message:Message),
  (reply)-[:HAS_TAG]->(tag:Tag)
WHERE NOT (message)-[:HAS_TAG]->(:Tag)<-[:HAS_TAG]-(reply)
  AND size([word IN blacklist WHERE reply.content CONTAINS word | word]) = 0 //Indice de texto sobre reply.content
OPTIONAL MATCH
  (:Person)-[like:LIKES]->(reply)
RETURN
  person.id,
  tag.name,
  count(DISTINCT like) AS countLikes,
  count(DISTINCT reply) AS countReplies
ORDER BY
  countLikes DESC,
  person.id ASC,
  tag.name ASC
LIMIT 100

//Estrategia de optimización
//Materialización
MATCH
  (country:Country)<-[:IS_PART_OF]-(:City)<-[:isLocatedIn]-(person:Person)
CREATE (country)<-[:BI_country_person]-(person)


//Consulta modificada
WITH ['also', 'Pope', 'that', 'James', 'Henry', 'one', 'Green'] AS blacklist
MATCH
  (country:Country {name: 'Germany'})<-[:BI_country_person]-
  (person:Person)<-[:HAS_CREATOR]-(reply:Comment)-[:REPLY_OF]->(message:Message),
  (reply)-[:HAS_TAG]->(tag:Tag)
WHERE NOT EXISTS {
  MATCH (message)-[:HAS_TAG]->(:Tag)<-[:HAS_TAG]-(reply)
}
  AND NONE(word IN blacklist WHERE reply.content CONTAINS word)
OPTIONAL MATCH
  (:Person)-[like:LIKES]->(reply)
WITH count(DISTINCT like) AS countLikes, count(DISTINCT reply) AS countReplies, tag, person
ORDER BY
  countLikes DESC,
  person.id ASC,
  tag.name ASC
LIMIT 100
RETURN
  person.id,
  tag.name,
  countLikes,
  countReplies