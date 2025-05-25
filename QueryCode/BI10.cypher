/// Consulta 10 

MATCH (tag:Tag {name: 'John_Rhys-Davies'})
OPTIONAL MATCH (tag)<-[interest:HAS_INTEREST]-(person:Person)
WITH tag, collect(person) AS interestedPersons
OPTIONAL MATCH (tag)<-[:HAS_TAG]-(message:Message)-[:HAS_CREATOR]->(person:Person)
WHERE datetime(message.creationDate) > datetime("2012-01-22T00:00:00.000+0000")
WITH tag, interestedPersons, collect(person) AS taggedPersons
UNWIND interestedPersons + taggedPersons AS person
WITH DISTINCT tag, person
WITH 
  tag, 
  person, 
  100 * size([(tag)<-[interest:HAS_INTEREST]-(person) | interest]) 
    + size([(tag)<-[:HAS_TAG]-(message:Message)-[:HAS_CREATOR]->(person) WHERE datetime(message.creationDate) > datetime("2012-01-22T00:00:00.000+0000") | message]) 
  AS score
OPTIONAL MATCH (person)-[:KNOWS]-(friend)
WITH 
  person, 
  score, 
  100 * size([(tag)<-[interest:HAS_INTEREST]-(friend) | interest]) 
    + size([(tag)<-[:HAS_TAG]-(message:Message)-[:HAS_CREATOR]->(friend) WHERE datetime(message.creationDate) > datetime("2012-01-22T00:00:00.000+0000") | message]) 
  AS friendScore
RETURN 
  person.id, 
  score, 
  sum(friendScore) AS friendsScore // aqui es que se tarda
ORDER BY 
  score + friendsScore DESC,  // aqui es que se tarda
  person.id ASC
LIMIT 100;