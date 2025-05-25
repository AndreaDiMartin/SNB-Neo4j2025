//CONSULTA 18

MATCH (person:Person)
OPTIONAL MATCH (person)<-[:HAS_CREATOR]-(message:Message)-[:REPLY_OF*0..]->(post:Post)
WHERE message.content IS NOT NULL
  AND message.length < 20
  AND message.creationDate > datetime('2011-07-22T00:00:00')
  AND post.language IN ['ar']
WITH
  person,
  count(message) AS messageCount
RETURN
  messageCount,
  count(person) AS personCount
ORDER BY
  personCount DESC,
  messageCount DESC

//Estrategia de optimización
//Materialización
MATCH (message:Message)-[:REPLY_OF*0..]->(post:Message) CREATE (message)-[:BI18_message]->(post)

//Consulta modificada
MATCH (person:Person) 
OPTIONAL MATCH (person)<-[:HAS_CREATOR]-(message:Message)-[:BI18_message]->(post:Post) 
WHERE message.content IS NOT NULL 
AND message.length < 20 
AND message.creationDate > datetime('2011-07-22T00:00:00') 
AND post.language IN ['ar'] 
WITH person, count(message) AS messageCount 
RETURN messageCount, count(person) AS personCount 
ORDER BY personCount 
DESC, messageCount DESC
