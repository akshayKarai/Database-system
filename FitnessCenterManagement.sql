-- phpMyAdmin SQL Dump
-- version 4.0.10deb1
-- http://www.phpmyadmin.net
--
-- Host: 127.0.0.1
-- Generation Time: Dec 04, 2017 at 09:42 PM
-- Server version: 5.5.57-0ubuntu0.14.04.1
-- PHP Version: 5.5.9-1ubuntu4.22

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `FitnessCenterManagement`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`gmontane`@`%` PROCEDURE `FitnessCourseAddition`(IN CourseName varchar(20), IN Typ Varchar(20), IN MaxStudents INT(20), IN CourseAddedBy INT(20))
BEGIN
DECLARE TypeID INT;
IF NOT EXISTS (SELECT * FROM FitnessCourse where FitnessCourseName=CourseName) THEN 
  IF NOT EXISTS (SELECT * FROM FitnessCourseType where FitnessCourseTypeName=Typ) THEN 
    INSERT INTO FitnessCourseType(FitnessCourseTypeName) VALUES (Typ);
    SET TypeID=(SELECT FitnessCourseTypeID FROM FitnessCourseType WHERE FitnessCourseTypeName=Typ);
    INSERT INTO FitnessCourse(FitnessCourseName,FitnessCourseTypeID,MaxNoOfStudents,FitnessCourseAddedBy) VALUES (CourseName,TypeID,MaxStudents,CourseAddedBy);
  ELSE 
    SET TypeID=(SELECT FitnessCourseTypeID FROM FitnessCourseType WHERE FitnessCourseTypeName=Typ);
    INSERT INTO FitnessCourse(FitnessCourseName,FitnessCourseTypeID,MaxNoOfStudents,FitnessCourseAddedBy) VALUES (CourseName,TypeID,MaxStudents,CourseAddedBy);
  END IF;
ELSE
SELECT 'Course Already Exists' AS Message;
END IF; 
END$$

CREATE DEFINER=`gmontane`@`%` PROCEDURE `FitnessCourseTrainerAssignment`(in CourseName varchar(20), IN TrainerEmailID Varchar(20), IN AssignedBy INT(20))
BEGIN
DECLARE CourseID INT;
DECLARE Trainer INT;

IF  EXISTS (SELECT * FROM FitnessCourse where FitnessCourseName=CourseName) 
THEN
   SET CourseID = (SELECT FitnessCourseID FROM FitnessCourse where FitnessCourseName=CourseName);
     
  IF  EXISTS (SELECT * FROM Trainer T JOIN Employee E ON E.EmployeeID=T.TrainerID
                 Where E.Email_ID=TrainerEmailID) 
  THEN
      SET Trainer=(SELECT EmployeeID FROM Employee WHERE Email_ID=TrainerEmailID);
      INSERT INTO CourseTrainer(FitnessCourseID,TrainerID,TrainerAssignedBy)                         
VALUES (CourseID,Trainer,AssignedBy);

  ELSE
  SELECT 'Trainer does not Exists';
  END IF; 
ELSE 
SELECT 'Course Does not exists';
END IF;
END$$

CREATE DEFINER=`gmontane`@`%` PROCEDURE `GetFitnessCoursesTypeListing`(IN typ VARCHAR(20))
BEGIN SELECT FitnessCourseName
From FitnessCourse FC
INNER JOIN FitnessCourseType FT ON FT.FitnessCourseTypeID=FC.FitnessCourseTypeID 
Where FT.FitnessCourseTypeName = typ;
END$$

CREATE DEFINER=`gmontane`@`%` PROCEDURE `GetMemberCourseDetails`(IN Email VARCHAR(20))
BEGIN 
SELECT FitnessCourseName, Start_time AS 'Start Time',End_time AS 'End Time', WeekDay AS 'Day of the Week', CONCAT(E.First_Name, ' ', E.Last_name) AS Trainer
FROM Registration R 
INNER JOIN Member M ON M.MemberID=R.MemberID
INNER JOIN FitnessCourse  FS ON R.FitnessCourseID=FS.FitnessCourseID
INNER JOIN CourseSchedule CS ON CS.FitnessCourseID=FS.FitnessCourseID

INNER JOIN WeeklySchedule WS ON WS.WeeklyScheduleID=CS.WeeklyScheduleID
INNER JOIN Trainer T ON T.TrainerID=CS.TrainerID
INNER JOIN Employee  E ON E.EmployeeID=T.TrainerID
WHERE M.Email_ID=Email and M.StatusID=1
ORDER BY FitnessCourseName;

END$$

CREATE DEFINER=`gmontane`@`%` PROCEDURE `GetTrainerFitnessCourses`(IN firstname VARCHAR(20), lastname VARCHAR(20))
BEGIN 
SELECT Concat(First_name, '', Last_name) TrainerName, 
FitnessCourseName 
FROM Employee e
INNER JOIN CourseTrainer t
ON e.employeeID = t.trainerID
INNER JOIN FitnessCourse  FC ON FC.FitnessCourseID=t.FitnessCourseID
WHERE First_name=firstname and Last_Name=lastname; 
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `Building`
--

CREATE TABLE IF NOT EXISTS `Building` (
  `BuildingID` int(20) NOT NULL AUTO_INCREMENT,
  `BuildingName` varchar(20) NOT NULL,
  PRIMARY KEY (`BuildingID`),
  KEY `BuildingID` (`BuildingID`),
  KEY `BuildingName` (`BuildingName`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=3 ;

--
-- Dumping data for table `Building`
--

INSERT INTO `Building` (`BuildingID`, `BuildingName`) VALUES
(2, 'BigHall1'),
(1, 'Gymnasium');

-- --------------------------------------------------------

--
-- Table structure for table `CourseSchedule`
--

CREATE TABLE IF NOT EXISTS `CourseSchedule` (
  `CourseScheduleID` int(20) NOT NULL AUTO_INCREMENT,
  `FitnessCourseID` int(20) NOT NULL,
  `WeeklyScheduleID` int(20) NOT NULL,
  `TrainerID` int(20) NOT NULL,
  `RoomID` int(20) NOT NULL,
  `ScheduledBy` int(20) NOT NULL,
  PRIMARY KEY (`CourseScheduleID`),
  KEY `TrainerID` (`TrainerID`),
  KEY `ScheduledBy` (`ScheduledBy`),
  KEY `CourseScheduleID` (`CourseScheduleID`),
  KEY `WeeklyScheduleId` (`WeeklyScheduleID`),
  KEY `FitnessCourseId` (`FitnessCourseID`),
  KEY `RoomId` (`RoomID`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=8 ;

--
-- Dumping data for table `CourseSchedule`
--

INSERT INTO `CourseSchedule` (`CourseScheduleID`, `FitnessCourseID`, `WeeklyScheduleID`, `TrainerID`, `RoomID`, `ScheduledBy`) VALUES
(1, 1, 1, 3, 1, 1),
(2, 1, 2, 3, 1, 1),
(3, 1, 5, 3, 1, 1),
(4, 2, 1, 4, 2, 2),
(5, 2, 4, 4, 3, 2),
(6, 3, 3, 6, 4, 2),
(7, 4, 5, 5, 5, 1);

-- --------------------------------------------------------

--
-- Table structure for table `CourseTrainer`
--

CREATE TABLE IF NOT EXISTS `CourseTrainer` (
  `CourseTrainerID` int(20) NOT NULL AUTO_INCREMENT,
  `FitnessCourseID` int(20) NOT NULL,
  `TrainerID` int(20) NOT NULL,
  `TrainerAssignedBy` int(20) NOT NULL,
  PRIMARY KEY (`CourseTrainerID`),
  KEY `CourseTrainerId` (`CourseTrainerID`),
  KEY `FitnessCourseId` (`FitnessCourseID`),
  KEY `TrainerId` (`TrainerID`),
  KEY `TrainerAssignedby` (`TrainerAssignedBy`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=8 ;

--
-- Dumping data for table `CourseTrainer`
--

INSERT INTO `CourseTrainer` (`CourseTrainerID`, `FitnessCourseID`, `TrainerID`, `TrainerAssignedBy`) VALUES
(1, 2, 3, 2),
(2, 2, 4, 1),
(3, 1, 6, 1),
(4, 1, 5, 2),
(5, 5, 7, 1),
(6, 4, 3, 2),
(7, 1, 4, 2);

-- --------------------------------------------------------

--
-- Table structure for table `Employee`
--

CREATE TABLE IF NOT EXISTS `Employee` (
  `EmployeeID` int(11) NOT NULL AUTO_INCREMENT,
  `First_name` varchar(20) NOT NULL,
  `Last_name` varchar(20) NOT NULL,
  `Street` varchar(20) NOT NULL,
  `Zip_code` varchar(20) NOT NULL,
  `Phone_number` varchar(20) NOT NULL,
  `Email_ID` varchar(20) NOT NULL,
  `StatusID` int(20) NOT NULL,
  PRIMARY KEY (`EmployeeID`),
  KEY `EmployeeID` (`EmployeeID`),
  KEY `FullName` (`First_name`,`Last_name`),
  KEY `Zipcode` (`Zip_code`),
  KEY `Statusid` (`StatusID`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=8 ;

--
-- Dumping data for table `Employee`
--

INSERT INTO `Employee` (`EmployeeID`, `First_name`, `Last_name`, `Street`, `Zip_code`, `Phone_number`, `Email_ID`, `StatusID`) VALUES
(1, 'James', 'Jones', '9407 Kittansett dr', '28262', '7049042812', 'james@gmail.com', 1),
(2, 'Dwayne', 'Johnson', '907 barton creek dr', '28266', '7041232812', 'john@gmail.com', 1),
(3, 'Steph', 'Curry', '937 ramsey creek dr', '28292', '9048942812', 'steph@gmail.com', 1),
(4, 'Ryan', 'Anderson', '988 Tryon dr', '28353', '8887042866', 'ryan@gmail.com', 1),
(5, 'Glen', 'Robinson', '777 Kittansett dr', '28262', '7754652812', 'glen@gmail.com', 1),
(6, 'Daisy', 'Mathews', '1924 Hunt Road', '29231', '7049046584', 'daisy@gmail.com', 1),
(7, 'Michael', 'Allen', '965 Norman dr', '28287', '9956657712', 'allen@gmail.com', 1);

-- --------------------------------------------------------

--
-- Table structure for table `FitnessCourse`
--

CREATE TABLE IF NOT EXISTS `FitnessCourse` (
  `FitnessCourseID` int(20) NOT NULL AUTO_INCREMENT,
  `FitnessCourseName` varchar(20) NOT NULL,
  `FitnessCourseTypeID` int(20) NOT NULL,
  `MaxNoOfStudents` int(20) NOT NULL,
  `FitnessCourseAddedBy` int(20) NOT NULL,
  PRIMARY KEY (`FitnessCourseID`),
  KEY `FitnessCourseID` (`FitnessCourseID`),
  KEY `FitnessCourseName` (`FitnessCourseName`),
  KEY `Fitnesscourseaddedby` (`FitnessCourseAddedBy`),
  KEY `FitnessCourseTypeid` (`FitnessCourseTypeID`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=7 ;

--
-- Dumping data for table `FitnessCourse`
--

INSERT INTO `FitnessCourse` (`FitnessCourseID`, `FitnessCourseName`, `FitnessCourseTypeID`, `MaxNoOfStudents`, `FitnessCourseAddedBy`) VALUES
(1, 'CardioKick', 1, 25, 2),
(2, 'VinyasaYoga', 2, 35, 1),
(3, 'Zumba', 3, 50, 1),
(4, 'BodyPump', 2, 15, 1),
(5, 'WaterCardio', 1, 10, 2),
(6, 'kungfu', 4, 100, 1);

-- --------------------------------------------------------

--
-- Stand-in structure for view `FitnessCourseScheduleDetails`
--
CREATE TABLE IF NOT EXISTS `FitnessCourseScheduleDetails` (
`FitnessCourseName` varchar(20)
,`Start Time` time
,`End Time` time
,`Day of the Week` varchar(20)
,`Trainer` varchar(41)
);
-- --------------------------------------------------------

--
-- Table structure for table `FitnessCourseType`
--

CREATE TABLE IF NOT EXISTS `FitnessCourseType` (
  `FitnessCourseTypeID` int(20) NOT NULL AUTO_INCREMENT,
  `FitnessCourseTypeName` varchar(20) NOT NULL,
  PRIMARY KEY (`FitnessCourseTypeID`),
  KEY `FitnessCourseTypeID` (`FitnessCourseTypeID`),
  KEY `FitnessCourseTypeName` (`FitnessCourseTypeName`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=5 ;

--
-- Dumping data for table `FitnessCourseType`
--

INSERT INTO `FitnessCourseType` (`FitnessCourseTypeID`, `FitnessCourseTypeName`) VALUES
(4, '1'),
(1, 'Cardio'),
(2, 'StrengthTraining'),
(3, 'Toning');

-- --------------------------------------------------------

--
-- Table structure for table `Manager`
--

CREATE TABLE IF NOT EXISTS `Manager` (
  `ManagerID` int(11) NOT NULL,
  `Annual_Salary` float NOT NULL,
  PRIMARY KEY (`ManagerID`),
  KEY `Managerid` (`ManagerID`),
  KEY `AnnualSalary` (`Annual_Salary`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `Manager`
--

INSERT INTO `Manager` (`ManagerID`, `Annual_Salary`) VALUES
(1, 8000),
(2, 8000);

-- --------------------------------------------------------

--
-- Table structure for table `Member`
--

CREATE TABLE IF NOT EXISTS `Member` (
  `MemberID` int(11) NOT NULL AUTO_INCREMENT,
  `First_name` varchar(20) NOT NULL,
  `Last_name` varchar(20) NOT NULL,
  `Street` varchar(20) NOT NULL,
  `Zip_code` varchar(20) NOT NULL,
  `Phone_number` varchar(20) NOT NULL,
  `Email_ID` varchar(20) NOT NULL,
  `StatusID` int(20) NOT NULL,
  PRIMARY KEY (`MemberID`),
  KEY `MemberID` (`MemberID`),
  KEY `Email_ID` (`Email_ID`),
  KEY `Zipcode` (`Zip_code`),
  KEY `StatusId` (`StatusID`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=13 ;

--
-- Dumping data for table `Member`
--

INSERT INTO `Member` (`MemberID`, `First_name`, `Last_name`, `Street`, `Zip_code`, `Phone_number`, `Email_ID`, `StatusID`) VALUES
(1, 'Joseph', 'Smith', '1061 E Main St', '26282', '7875438745', 'jos@gmail.com', 1),
(2, 'Mark', 'Henry', '10 Downing Rd', '37681', '9804568732', 'markhen@yahoo.com', 1),
(3, 'Julia', 'Robert', '103 River Rd', '26900', '8761295345', 'juliaro@yahoo.com', 1),
(4, 'Aaron', 'Finch', '2345 Park Ave', '45876', '9883257865', 'aafin@gmail.com', 1),
(5, 'Steve', 'Waugh', '345 University Rd', '14589', '7658684352', 'stewa@gmail.com', 1),
(6, 'Lebron', 'James', '108 H brussels St', '26333', '9975438745', 'LJ@gmail.com', 1),
(7, 'Dwight', 'Howard', '247 Church St', '28656', '9999938745', 'Howard@gmail.com', 1),
(8, 'Andre', 'Miller', '256 Church Main St', '26299', '7877894745', 'Andre@gmail.com', 1),
(9, 'Denzel', 'Valentine', '999 Kittansett Dr', '26344', '7321338745', 'Denzel@gmail.com', 1),
(10, 'Kyrie', 'Irving', '900 Kittansett Dr', '26346', '9861338745', 'Kyrie@gmail.com', 1),
(11, 'Draymond', 'Green', 'Barton Dr', '26546', '6661338745', 'Green@gmail.com', 1),
(12, 'Nick', 'Young', '901 Kittansett Dr', '26346', '9111338745', 'Young@gmail.com', 1);

-- --------------------------------------------------------

--
-- Stand-in structure for view `MemberListingForFitnessCourses`
--
CREATE TABLE IF NOT EXISTS `MemberListingForFitnessCourses` (
`FitnessCourseName` varchar(20)
,`NameofMember` varchar(41)
,`Email_ID` varchar(20)
,`Phone_number` varchar(20)
,`Address` varchar(43)
,`State` varchar(20)
,`Zip_code` varchar(20)
);
-- --------------------------------------------------------

--
-- Table structure for table `Registration`
--

CREATE TABLE IF NOT EXISTS `Registration` (
  `RegistrationID` int(11) NOT NULL AUTO_INCREMENT,
  `FitnessCourseID` int(11) NOT NULL,
  `MemberID` int(11) NOT NULL,
  `Registration_Date` datetime NOT NULL,
  PRIMARY KEY (`RegistrationID`),
  KEY `RegistrationID` (`RegistrationID`),
  KEY `FitnessCourseId` (`FitnessCourseID`),
  KEY `MemberId` (`MemberID`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=19 ;

--
-- Dumping data for table `Registration`
--

INSERT INTO `Registration` (`RegistrationID`, `FitnessCourseID`, `MemberID`, `Registration_Date`) VALUES
(1, 1, 2, '2011-02-17 00:00:00'),
(2, 2, 3, '2011-02-17 00:00:00'),
(3, 3, 4, '2011-01-17 00:00:00'),
(4, 4, 5, '2011-01-17 00:00:00'),
(5, 5, 1, '2011-03-17 00:00:00'),
(6, 5, 6, '2011-05-17 00:00:00'),
(7, 4, 7, '2011-08-17 00:00:00'),
(8, 3, 8, '2011-06-17 00:00:00'),
(9, 1, 9, '2011-04-17 00:00:00'),
(10, 1, 11, '2011-04-17 00:00:00'),
(11, 5, 12, '2011-04-17 00:00:00'),
(12, 3, 1, '2011-06-17 00:00:00'),
(13, 3, 2, '2011-06-17 00:00:00'),
(14, 3, 3, '2011-06-17 00:00:00'),
(15, 3, 5, '2011-06-17 00:00:00'),
(16, 3, 6, '2011-06-17 00:00:00'),
(17, 3, 7, '2011-06-17 00:00:00'),
(18, 1, 10, '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Table structure for table `Room`
--

CREATE TABLE IF NOT EXISTS `Room` (
  `RoomID` int(20) NOT NULL AUTO_INCREMENT,
  `RoomNumber` varchar(20) NOT NULL,
  `BuildingID` int(20) NOT NULL,
  PRIMARY KEY (`RoomID`),
  KEY `RoomID` (`RoomID`),
  KEY `BuildingId` (`BuildingID`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=7 ;

--
-- Dumping data for table `Room`
--

INSERT INTO `Room` (`RoomID`, `RoomNumber`, `BuildingID`) VALUES
(1, '102', 1),
(2, '103', 1),
(3, '104', 1),
(4, '105', 1),
(5, '101', 2),
(6, '102', 2);

-- --------------------------------------------------------

--
-- Table structure for table `Status`
--

CREATE TABLE IF NOT EXISTS `Status` (
  `StatusID` int(11) NOT NULL AUTO_INCREMENT,
  `StatusName` varchar(20) NOT NULL,
  PRIMARY KEY (`StatusID`),
  KEY `Statusid` (`StatusID`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=3 ;

--
-- Dumping data for table `Status`
--

INSERT INTO `Status` (`StatusID`, `StatusName`) VALUES
(1, 'Active'),
(2, 'Inactive');

-- --------------------------------------------------------

--
-- Stand-in structure for view `TotalMembersForFitnessCourse`
--
CREATE TABLE IF NOT EXISTS `TotalMembersForFitnessCourse` (
`FitnessCourseName` varchar(20)
,`Total Registered Members` bigint(21)
,`MaxNoOfStudentsAllowed` int(20)
);
-- --------------------------------------------------------

--
-- Table structure for table `Trainer`
--

CREATE TABLE IF NOT EXISTS `Trainer` (
  `TrainerID` int(11) NOT NULL,
  `Hourly_Salary` float NOT NULL,
  `Hours_Worked` float NOT NULL,
  PRIMARY KEY (`TrainerID`),
  KEY `Trainerid` (`TrainerID`),
  KEY `HourlySalary` (`Hourly_Salary`),
  KEY `HoursWorked` (`Hours_Worked`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `Trainer`
--

INSERT INTO `Trainer` (`TrainerID`, `Hourly_Salary`, `Hours_Worked`) VALUES
(3, 14.5, 35),
(4, 17, 40),
(5, 15.55, 32.5),
(6, 15.75, 20),
(7, 16.25, 16);

-- --------------------------------------------------------

--
-- Table structure for table `WeeklySchedule`
--

CREATE TABLE IF NOT EXISTS `WeeklySchedule` (
  `WeeklyScheduleID` int(20) NOT NULL AUTO_INCREMENT,
  `Start_time` time NOT NULL,
  `End_time` time NOT NULL,
  `WeekDay` varchar(20) NOT NULL,
  PRIMARY KEY (`WeeklyScheduleID`),
  KEY `WeeklyScheduleID` (`WeeklyScheduleID`),
  KEY `Time` (`Start_time`,`End_time`,`WeekDay`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=10 ;

--
-- Dumping data for table `WeeklySchedule`
--

INSERT INTO `WeeklySchedule` (`WeeklyScheduleID`, `Start_time`, `End_time`, `WeekDay`) VALUES
(3, '08:30:00', '10:30:00', 'Friday'),
(1, '08:30:00', '10:30:00', 'Monday'),
(2, '08:30:00', '10:30:00', 'Wednesday'),
(5, '09:30:00', '11:30:00', 'Saturday'),
(4, '09:30:00', '11:30:00', 'Wednesday'),
(6, '10:00:00', '11:30:00', 'Tuesday'),
(9, '17:30:00', '19:30:00', 'Thursday'),
(7, '18:30:00', '20:30:00', 'Friday'),
(8, '18:30:00', '20:30:00', 'Tuesday');

-- --------------------------------------------------------

--
-- Table structure for table `Zipcode`
--

CREATE TABLE IF NOT EXISTS `Zipcode` (
  `Zip_code` varchar(20) NOT NULL,
  `City` varchar(20) NOT NULL,
  `State` varchar(20) NOT NULL,
  PRIMARY KEY (`Zip_code`),
  KEY `zipcode` (`Zip_code`),
  KEY `City` (`City`),
  KEY `State` (`State`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `Zipcode`
--

INSERT INTO `Zipcode` (`Zip_code`, `City`, `State`) VALUES
('14589', 'Durham', 'North Carolina'),
('26282', 'Charlotte', 'North Carolina'),
('26299', 'Charlotte', 'North Carolina'),
('26333', 'Charlotte', 'North Carolina'),
('26344', 'Charlotte', 'North Carolina'),
('26346', 'Charlotte', 'North Carolina'),
('26546', 'Charlotte', 'North Carolina'),
('26900', 'Charlotte', 'North Carolina'),
('28262', 'Charlotte', 'North Carolina'),
('28266', 'Charlotte', 'North Carolina'),
('28287', 'Asheville', 'North Carolina'),
('28292', 'Greensboro', 'North Carolina'),
('28353', 'Charlotte', 'North Carolina'),
('28656', 'Charlotte', 'North Carolina'),
('29231', 'Huntersville', 'North Carolina'),
('37681', 'Greensboro', 'North Carolina'),
('45876', 'Chapel Hill', 'North Carolina');

-- --------------------------------------------------------

--
-- Structure for view `FitnessCourseScheduleDetails`
--
DROP TABLE IF EXISTS `FitnessCourseScheduleDetails`;

CREATE ALGORITHM=UNDEFINED DEFINER=`gmontane`@`%` SQL SECURITY DEFINER VIEW `FitnessCourseScheduleDetails` AS select `FS`.`FitnessCourseName` AS `FitnessCourseName`,`WS`.`Start_time` AS `Start Time`,`WS`.`End_time` AS `End Time`,`WS`.`WeekDay` AS `Day of the Week`,concat(`E`.`First_name`,' ',`E`.`Last_name`) AS `Trainer` from ((((`CourseSchedule` `CS` join `FitnessCourse` `FS` on((`CS`.`FitnessCourseID` = `FS`.`FitnessCourseID`))) join `WeeklySchedule` `WS` on((`WS`.`WeeklyScheduleID` = `CS`.`WeeklyScheduleID`))) join `Trainer` `T` on((`T`.`TrainerID` = `CS`.`TrainerID`))) join `Employee` `E` on((`E`.`EmployeeID` = `T`.`TrainerID`))) order by `FS`.`FitnessCourseName`;

-- --------------------------------------------------------

--
-- Structure for view `MemberListingForFitnessCourses`
--
DROP TABLE IF EXISTS `MemberListingForFitnessCourses`;

CREATE ALGORITHM=UNDEFINED DEFINER=`gmontane`@`%` SQL SECURITY DEFINER VIEW `MemberListingForFitnessCourses` AS select `F`.`FitnessCourseName` AS `FitnessCourseName`,concat_ws(' ',`M`.`First_name`,`M`.`Last_name`) AS `NameofMember`,`M`.`Email_ID` AS `Email_ID`,`M`.`Phone_number` AS `Phone_number`,concat_ws(' ',`M`.`Street`,',',`Z`.`City`) AS `Address`,`Z`.`State` AS `State`,`M`.`Zip_code` AS `Zip_code` from (((`FitnessCourse` `F` join `Registration` `R` on((`R`.`FitnessCourseID` = `F`.`FitnessCourseID`))) join `Member` `M` on((`M`.`MemberID` = `R`.`MemberID`))) join `Zipcode` `Z` on((`Z`.`Zip_code` = `M`.`Zip_code`))) order by `F`.`FitnessCourseName`;

-- --------------------------------------------------------

--
-- Structure for view `TotalMembersForFitnessCourse`
--
DROP TABLE IF EXISTS `TotalMembersForFitnessCourse`;

CREATE ALGORITHM=UNDEFINED DEFINER=`gmontane`@`%` SQL SECURITY DEFINER VIEW `TotalMembersForFitnessCourse` AS select `F`.`FitnessCourseName` AS `FitnessCourseName`,count(`R`.`MemberID`) AS `Total Registered Members`,`F`.`MaxNoOfStudents` AS `MaxNoOfStudentsAllowed` from ((`FitnessCourse` `F` join `Registration` `R` on((`R`.`FitnessCourseID` = `F`.`FitnessCourseID`))) join `Member` `M` on(((`M`.`MemberID` = `R`.`MemberID`) and (`M`.`StatusID` = 1)))) group by `F`.`FitnessCourseID` order by `F`.`FitnessCourseName`;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `CourseSchedule`
--
ALTER TABLE `CourseSchedule`
  ADD CONSTRAINT `CourseSchedule_ibfk_1` FOREIGN KEY (`FitnessCourseID`) REFERENCES `FitnessCourse` (`FitnessCourseID`),
  ADD CONSTRAINT `CourseSchedule_ibfk_2` FOREIGN KEY (`WeeklyScheduleID`) REFERENCES `WeeklySchedule` (`WeeklyScheduleID`),
  ADD CONSTRAINT `CourseSchedule_ibfk_3` FOREIGN KEY (`TrainerID`) REFERENCES `Trainer` (`TrainerID`),
  ADD CONSTRAINT `CourseSchedule_ibfk_4` FOREIGN KEY (`RoomID`) REFERENCES `Room` (`RoomID`),
  ADD CONSTRAINT `CourseSchedule_ibfk_5` FOREIGN KEY (`ScheduledBy`) REFERENCES `Manager` (`ManagerID`);

--
-- Constraints for table `CourseTrainer`
--
ALTER TABLE `CourseTrainer`
  ADD CONSTRAINT `CourseTrainer_ibfk_1` FOREIGN KEY (`FitnessCourseID`) REFERENCES `FitnessCourse` (`FitnessCourseID`),
  ADD CONSTRAINT `CourseTrainer_ibfk_2` FOREIGN KEY (`TrainerID`) REFERENCES `Trainer` (`TrainerID`),
  ADD CONSTRAINT `CourseTrainer_ibfk_3` FOREIGN KEY (`TrainerAssignedBy`) REFERENCES `Manager` (`ManagerID`);

--
-- Constraints for table `Employee`
--
ALTER TABLE `Employee`
  ADD CONSTRAINT `Employee_ibfk_1` FOREIGN KEY (`Zip_code`) REFERENCES `Zipcode` (`Zip_code`),
  ADD CONSTRAINT `Employee_ibfk_2` FOREIGN KEY (`StatusID`) REFERENCES `Status` (`StatusID`);

--
-- Constraints for table `FitnessCourse`
--
ALTER TABLE `FitnessCourse`
  ADD CONSTRAINT `FitnessCourse_ibfk_1` FOREIGN KEY (`FitnessCourseAddedBy`) REFERENCES `Manager` (`ManagerID`),
  ADD CONSTRAINT `FitnessCourse_ibfk_2` FOREIGN KEY (`FitnessCourseTypeID`) REFERENCES `FitnessCourseType` (`FitnessCourseTypeID`);

--
-- Constraints for table `Manager`
--
ALTER TABLE `Manager`
  ADD CONSTRAINT `Manager_ibfk_1` FOREIGN KEY (`ManagerID`) REFERENCES `Employee` (`EmployeeID`);

--
-- Constraints for table `Member`
--
ALTER TABLE `Member`
  ADD CONSTRAINT `Member_ibfk_1` FOREIGN KEY (`Zip_code`) REFERENCES `Zipcode` (`Zip_code`),
  ADD CONSTRAINT `Member_ibfk_2` FOREIGN KEY (`StatusID`) REFERENCES `Status` (`StatusID`);

--
-- Constraints for table `Registration`
--
ALTER TABLE `Registration`
  ADD CONSTRAINT `Registration_ibfk_1` FOREIGN KEY (`FitnessCourseID`) REFERENCES `FitnessCourse` (`FitnessCourseID`),
  ADD CONSTRAINT `Registration_ibfk_2` FOREIGN KEY (`MemberID`) REFERENCES `Member` (`MemberID`);

--
-- Constraints for table `Room`
--
ALTER TABLE `Room`
  ADD CONSTRAINT `Room_ibfk_1` FOREIGN KEY (`BuildingID`) REFERENCES `Building` (`BuildingID`);

--
-- Constraints for table `Trainer`
--
ALTER TABLE `Trainer`
  ADD CONSTRAINT `Trainer_ibfk_1` FOREIGN KEY (`TrainerID`) REFERENCES `Employee` (`EmployeeID`);

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
