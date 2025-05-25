//CONSULTA 15

MATCH
  (country:Country {name: 'Burma'})
MATCH
  (country)<-[:IS_PART_OF]-(:City)<-[:isLocatedIn]-(person1:Person)
OPTIONAL MATCH
  (country)<-[:IS_PART_OF]-(:City)<-[:isLocatedIn]-(friend1:Person),
  (person1)-[:KNOWS]-(friend1)
WITH country, person1, count(friend1) AS friend1Count
WITH country, avg(friend1Count) AS socialNormalFloat
WITH country, floor(socialNormalFloat) AS socialNormal
MATCH
  (country)<-[:IS_PART_OF]-(:City)<-[:isLocatedIn]-(person2:Person)
OPTIONAL MATCH
  (country)<-[:IS_PART_OF]-(:City)<-[:isLocatedIn]-(friend2:Person)-[:KNOWS]-(person2)
WITH country, person2, count(friend2) AS friend2Count, socialNormal
WHERE friend2Count = socialNormal
RETURN
  person2.id,
  friend2Count AS count
ORDER BY
  person2.id ASC
LIMIT 100

//Estrategia de optimización
//Materialización
MATCH
  (country:Country)<-[:IS_PART_OF]-(:City)<-[:isLocatedIn]-(person:Person)
CREATE (country)<-[:BI_country_person]-(person)

//Consulta modificada
MATCH
  (country:Country {name: 'Burma'})
MATCH
  (country)<-[:BI_country_person]-(person1:Person)
OPTIONAL MATCH
  (country)<-[:BI_country_person]-(friend1:Person),
  (person1)-[:KNOWS]-(friend1)
WITH country, person1, count(friend1) AS friend1Count
WITH country, avg(friend1Count) AS socialNormalFloat
WITH country, floor(socialNormalFloat) AS socialNormal
MATCH
  (country)<-[:BI_country_person]-(person2:Person)
OPTIONAL MATCH
  (country)<-[:BI_country_person]-(friend2:Person)-[:KNOWS]-(person2)
WITH country, person2, count(friend2) AS friend2Count, socialNormal
WHERE friend2Count = socialNormal
RETURN
  person2.id,
  friend2Count AS count
ORDER BY
  person2.id ASC
LIMIT 100