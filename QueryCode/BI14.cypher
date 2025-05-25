//CONSULTA 14

MATCH (person:Person)<-[:HAS_CREATOR]-(post:Post)
<-[:REPLY_OF*0..]-(reply:Message)
WHERE  post.creationDate >= datetime('2012-05-31T22:00:00')
  AND  post.creationDate <= datetime('2012-06-30T22:00:00')
  AND reply.creationDate >= datetime('2012-05-31T22:00:00')
  AND reply.creationDate <= datetime('2012-06-30T22:00:00')
RETURN
  person.id,
  person.firstName,
  person.lastName,
  count(DISTINCT post) AS threadCount,
  count(DISTINCT reply) AS messageCount
ORDER BY
  messageCount DESC,
  person.id ASC
LIMIT 100

//Estrategia de optimización
//Indice
CREATE INDEX creation_date_post_index FOR (n:Post) ON (n.creationDate)