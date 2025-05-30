// CONSULTA 22
MATCH
  (country1:Country {name: 'Mexico'})<-[:IS_PART_OF]-(city1:City)<-[:IS_LOCATED_IN]-(person1:Person),
  (country2:Country {name: 'Indonesia'})<-[:IS_PART_OF]-(city2:City)<-[:IS_LOCATED_IN]-(person2:Person)
WITH person1, person2, city1, 0 AS score
// subscore 1
OPTIONAL MATCH (person1)<-[:HAS_CREATOR]-(c:Comment)-[:REPLY_OF]->(:Message)-[:HAS_CREATOR]->(person2)
WITH DISTINCT person1, person2, city1, score + (CASE c WHEN null THEN 0 ELSE  4 END) AS score
// subscore 2
OPTIONAL MATCH (person1)<-[:HAS_CREATOR]-(m:Message)<-[:REPLY_OF]-(:Comment)-[:HAS_CREATOR]->(person2)
WITH DISTINCT person1, person2, city1, score + (CASE m WHEN null THEN 0 ELSE  1 END) AS score
// subscore 3
OPTIONAL MATCH (person1)-[k:KNOWS]-(person2)
WITH DISTINCT person1, person2, city1, score + (CASE k WHEN null THEN 0 ELSE 15 END) AS score
// subscore 4
OPTIONAL MATCH (person1)-[:LIKES]->(m:Message)-[:HAS_CREATOR]->(person2)
WITH DISTINCT person1, person2, city1, score + (CASE m WHEN null THEN 0 ELSE 10 END) AS score
// subscore 5
OPTIONAL MATCH (person1)<-[:HAS_CREATOR]-(m:Message)<-[:LIKES]-(person2)
WITH DISTINCT person1, person2, city1, score + (CASE m WHEN null THEN 0 ELSE  1 END) AS score
// preorder
ORDER BY
  city1.name ASC,
  score DESC,
  person1.id ASC,
  person2.id ASC
WITH
  city1,
  // using a list might be faster, but the browser query editor does not like it
  collect({score: score, person1: person1, person2: person2})[0] AS top
RETURN
  top.person1.id,
  top.person2.id,
  city1.name,
  top.score
ORDER BY
  top.score DESC,
  top.person1.id ASC,
  top.person2.id ASC



// ESTRATEGIA DE OPTIMIZACIÓN: MATERIALIZACIÓN
MATCH
  (person1:Person)
MATCH (person1)<-[:HAS_CREATOR]-(c:Comment)-[:REPLY_OF]->(:Message)-[:HAS_CREATOR]->(person2:Person)
CREATE (person1)-[:BI22_person_person_subscore1_2]->(person2);

MATCH
  (person1:Person)
MATCH (person1)-[:LIKES]->(m:Message)-[:HAS_CREATOR]->(person2:Person)
CREATE (person1)<-[:BI22_person1_person2_subscore4_5]-(person2); 


// CONSULTA OPTIMIZADA
MATCH
  (country1:Country {name: 'Mexico'})<-[:IS_PART_OF]-(city1:City)<-[:IS_LOCATED_IN]-(person1:Person),
  (country2:Country {name: 'Indonesia'})<-[:IS_PART_OF]-(city2:City)<-[:IS_LOCATED_IN]-(person2:Person)
WITH person1, person2, city1, 0 AS score
// subscore 1
OPTIONAL MATCH (person1)-[c:BI22_person_person_subscore1_2]->(person2)
WITH DISTINCT person1, person2, city1, score + (CASE c WHEN null THEN 0 ELSE  4 END) AS score
// subscore 2
OPTIONAL MATCH (person1)<-[m:BI22_person_person_subscore1_2]-(person2)
WITH DISTINCT person1, person2, city1, score + (CASE m WHEN null THEN 0 ELSE  1 END) AS score
// subscore 3
OPTIONAL MATCH (person1)-[k:KNOWS]-(person2)
WITH DISTINCT person1, person2, city1, score + (CASE k WHEN null THEN 0 ELSE 15 END) AS score
// subscore 4
OPTIONAL MATCH (person1)<-[m:BI22_person1_person2_subscore4_5]-(person2)
WITH DISTINCT person1, person2, city1, score + (CASE m WHEN null THEN 0 ELSE 10 END) AS score
// subscore 5
OPTIONAL MATCH (person1)-[m:BI22_person1_person2_subscore4_5]->(person2)
WITH DISTINCT person1, person2, city1, score + (CASE m WHEN null THEN 0 ELSE  1 END) AS score
// preorder
ORDER BY
  city1.name ASC,
  score DESC,
  person1.id ASC,
  person2.id ASC
WITH
  city1,
  // using a list might be faster, but the browser query editor does not like it
  collect({score: score, person1: person1, person2: person2})[0] AS top
RETURN
  top.person1.id,
  top.person2.id,
  city1.name,
  top.score
ORDER BY
  top.score DESC,
  top.person1.id ASC,
  top.person2.id ASC 