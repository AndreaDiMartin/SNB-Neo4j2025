//CONSULTA 12

MATCH
  (message:Message)-[:HAS_CREATOR]->(creator:Person),
  (message)<-[like:LIKES]-(:Person)
WHERE message.creationDate > datetime('2011-07-21T22:00:00')
WITH message, creator, count(like) AS likeCount
WHERE likeCount > 400
RETURN
  message.id,
  message.creationDate,
  creator.firstName,
  creator.lastName,
  likeCount
ORDER BY
  likeCount DESC,
  message.id ASC
LIMIT 100

//Estrategia de optimización
//Materialización
MATCH
  (message:Message)-[:HAS_CREATOR]->(creator:Person),
  (message)<-[like:LIKES]-(:Person)
WITH message, creator, count(like) AS likeCount
CREATE(messageLikes: MessageLikes {likes: likeCount, messageCreationDate: message.creationDate, messageId:message.id} )
CREATE (messageLikes)-[:BI12_message_creator]->(creator)

//Consulta optimizada
MATCH
  (creator:Person)<-[:BI12_message_creator]-(message:MessageLikes)
WHERE message.messageCreationDate > datetime('2011-07-21T22:00:00')
WITH message, creator, message.likes AS likes
WHERE likes>400
RETURN
  message.messageId,
  message.messageCreationDate,
  creator.firstName,
  creator.lastName,
  likes
ORDER BY
  likes DESC,
  message.id ASC
LIMIT 100
