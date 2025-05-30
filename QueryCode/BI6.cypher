//CONSULTA 6

MATCH (tag:Tag {name: 'Abbas_I_of_Persia'})<-[:HAS_TAG]-(message:Message)-[:hasCreator]->(person:Person)
OPTIONAL MATCH (:Person)-[like:LIKES]->(message)
OPTIONAL MATCH (message)<-[:REPLY_OF]-(comment:Comment)
WITH person, count(DISTINCT like) AS likeCount, 
  count(DISTINCT comment) AS replyCount, 
  count(DISTINCT message) AS messageCount
RETURN
  person.id,
  replyCount,
  likeCount,
  messageCount,
  1*messageCount + 2*replyCount + 10*likeCount AS score
ORDER BY
  score DESC,
  person.id ASC
LIMIT 100

//Estrategia de optimización
//Indice
CREATE INDEX name_tag_index FOR (n:Tag) ON (n.name)