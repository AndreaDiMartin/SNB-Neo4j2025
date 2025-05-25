//CONSULTA B1

MATCH (message:Message)
WHERE message.creationDate < datetime('2011-07-21T22:00:00')
WITH count(message) AS totalMessageCountInt 
WITH toFloat(totalMessageCountInt) AS totalMessageCount
MATCH (message:Message)
WHERE message.creationDate < datetime('2011-07-21T22:00:00')
  AND message.content IS NOT NULL
WITH
  totalMessageCount,
  message,
  message.creationDate.year AS year
WITH
  totalMessageCount,
  year,
  message:Comment AS isComment,
  CASE
    WHEN message.length <  40 THEN 0
    WHEN message.length <  80 THEN 1
    WHEN message.length < 160 THEN 2
    ELSE                           3
  END AS lengthCategory,
  count(message) AS messageCount,
  floor(avg(message.length)) AS averageMessageLength,
  sum(message.length) AS sumMessageLength
RETURN
  year,
  isComment,
  lengthCategory,
  messageCount,
  averageMessageLength,
  sumMessageLength,
  messageCount / totalMessageCount AS percentageOfMessages
ORDER BY
  year DESC,
  isComment ASC,
  lengthCategory ASC

//Estrategifa de optimización
//Indice
CREATE INDEX creation_date_message_index FOR (n:Message) ON (n.creationDate)