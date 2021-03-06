USE [master]
GO
/****** Object:  Database [jobOpenings]    Script Date: 14-May-2022 3:30:03 PM ******/
CREATE DATABASE [jobOpenings]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'jobOpenings', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.VARAD\MSSQL\DATA\jobOpenings.mdf' , SIZE = 4096KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'jobOpenings_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.VARAD\MSSQL\DATA\jobOpenings_log.ldf' , SIZE = 1024KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [jobOpenings] SET COMPATIBILITY_LEVEL = 110
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [jobOpenings].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [jobOpenings] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [jobOpenings] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [jobOpenings] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [jobOpenings] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [jobOpenings] SET ARITHABORT OFF 
GO
ALTER DATABASE [jobOpenings] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [jobOpenings] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [jobOpenings] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [jobOpenings] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [jobOpenings] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [jobOpenings] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [jobOpenings] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [jobOpenings] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [jobOpenings] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [jobOpenings] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [jobOpenings] SET  DISABLE_BROKER 
GO
ALTER DATABASE [jobOpenings] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [jobOpenings] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [jobOpenings] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [jobOpenings] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [jobOpenings] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [jobOpenings] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [jobOpenings] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [jobOpenings] SET RECOVERY FULL 
GO
ALTER DATABASE [jobOpenings] SET  MULTI_USER 
GO
ALTER DATABASE [jobOpenings] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [jobOpenings] SET DB_CHAINING OFF 
GO
ALTER DATABASE [jobOpenings] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [jobOpenings] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
EXEC sys.sp_db_vardecimal_storage_format N'jobOpenings', N'ON'
GO
USE [jobOpenings]
GO
USE [jobOpenings]
GO
/****** Object:  Sequence [dbo].[seql_jobOpening]    Script Date: 14-May-2022 3:30:03 PM ******/
CREATE SEQUENCE [dbo].[seql_jobOpening] 
 AS [bigint]
 START WITH 1
 INCREMENT BY 1
 MINVALUE -9223372036854775808
 MAXVALUE 9223372036854775807
 CACHE 
GO
/****** Object:  StoredProcedure [dbo].[usp_jobDetails_populate]    Script Date: 14-May-2022 3:30:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_jobDetails_populate]
@p_id INT
AS
BEGIN

DECLARE @v_locId INT,@v_deptId INT

	SELECT j.id AS 'id'
      ,[job_code] AS 'code'
      ,[job_title] AS 'title'
      ,[job_description] AS 'description'
      ,[job_postedDate] AS 'postedDate'
      ,[job_closingDate] AS 'closingDate'
	FROM [jobOpenings].[dbo].[jobOpening_tbl] j
	INNER JOIN [dbo].[job_location_master] l ON j.job_location_id=l.job_location_id AND l.job_location_active=1
	INNER JOIN [dbo].[job_department_master] d ON j.job_department_id=d.job_department_id AND d.job_department_active=1
	WHERE [id]=@p_id
	AND job_active=1

	SELECT @v_locId=l.job_location_id,
	  @v_deptId=d.job_department_id
	FROM [jobOpenings].[dbo].[jobOpening_tbl] j
	INNER JOIN [dbo].[job_location_master] l ON j.job_location_id=l.job_location_id AND l.job_location_active=1
	INNER JOIN [dbo].[job_department_master] d ON j.job_department_id=d.job_department_id AND d.job_department_active=1
	WHERE [id]=@p_id
	AND job_active=1

	  SELECT job_location_id AS 'id',job_location_title AS 'title',job_location_city AS 'city',
	  job_location_state AS 'state',job_location_county AS 'country',job_location_zip AS 'zip'
	  FROM job_location_master
	  WHERE job_location_id=@v_locId
	  AND job_location_active=1

	  SELECT job_department_id AS 'id', job_department_title AS 'title'
	  FROM [job_department_master]
	  WHERE job_department_id=@v_deptId
	  AND job_department_active=1

END

GO
/****** Object:  StoredProcedure [dbo].[usp_jobList_populate]    Script Date: 14-May-2022 3:30:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_jobList_populate]
@p_q VARCHAR(100),
@p_pageNo INT,
@p_pageSize INT,
@p_locationId INT,
@p_departmentId INT
AS
BEGIN

	SELECT COUNT([id]) AS 'total'
	FROM [dbo].[jobOpening_tbl]
	WHERE[job_location_id] =@p_locationId
	AND [job_department_id]=@p_departmentId
	AND ([job_title] LIKE '%'+@p_q+'%' OR [job_description] LIKE '%'+@p_q+'%')

	SELECT * FROM
	(SELECT ROW_NUMBER() OVER(ORDER BY j.id DESC)AS RowNumber,
	j.id AS 'id'
      ,[job_code] AS 'code'
      ,[job_title] AS 'title'
   	  ,l.job_location_title AS 'location'
	  ,d.job_department_title AS 'department'
	  ,[job_postedDate] AS 'postedDate'
      ,[job_closingDate] AS 'closingDate'
	FROM [jobOpenings].[dbo].[jobOpening_tbl] j
	INNER JOIN [dbo].[job_location_master] l ON j.job_location_id=l.job_location_id AND l.job_location_active=1
	INNER JOIN [dbo].[job_department_master] d ON j.job_department_id=d.job_department_id AND d.job_department_active=1
	WHERE job_active=1
	AND ([job_title] LIKE '%'+@p_q+'%' OR [job_description] LIKE '%'+@p_q+'%')
	) t
	WHERE RowNumber BETWEEN(@p_pageNo -1) * @p_pageSize + 1   
					 AND (((@p_pageNo -1) * @p_pageSize + 1) + @p_pageSize) - 1 

END

GO
/****** Object:  StoredProcedure [dbo].[usp_jobOpening_save]    Script Date: 14-May-2022 3:30:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Varad>
-- Create date: <Create Date,06-May-2022,>
-- Description:	<Description,savejob opening,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_jobOpening_save]
@p_title VARCHAR(100),
@p_desc VARCHAR(100),
@p_locationId VARCHAR(100),
@p_deptId VARCHAR(100),
@p_closingDate DATETIME,
@p_id INT

AS
BEGIN

DECLARE @v_jobCode VARCHAR(20)

IF(@p_id='0')
	BEGIN
		SET @v_jobCode = 'JOB-'  +  FORMAT(NEXT VALUE FOR [dbo].[seql_jobOpening], '00000');

			INSERT INTO [dbo].[jobOpening_tbl](
				[job_code],			[job_title],		[job_description],		[job_postedDate],
				[job_closingDate],	[job_location_id],	[job_department_id])
			VALUES(
				@v_jobCode,			@p_title,			@p_desc,				GETDATE(),
				@p_closingDate,		@p_locationId,		@p_deptId)

			SELECT SCOPE_IDENTITY()
	END
ELSE
	BEGIN
		UPDATE [jobOpening_tbl]
		SET [job_title]=@p_title,[job_description]=@p_desc,[job_closingDate]=@p_closingDate,
		[job_location_id]=@p_locationId,[job_department_id]=@p_deptId
		WHERE [id]=@p_id

		SELECT @p_id
	END
END

GO
/****** Object:  Table [dbo].[job_department_master]    Script Date: 14-May-2022 3:30:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[job_department_master](
	[job_department_id] [int] NOT NULL,
	[job_department_title] [varchar](100) NOT NULL,
	[job_department_active] [bit] NOT NULL,
 CONSTRAINT [PK_job_department_master] PRIMARY KEY CLUSTERED 
(
	[job_department_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[job_location_master]    Script Date: 14-May-2022 3:30:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[job_location_master](
	[job_location_id] [bigint] NOT NULL,
	[job_location_title] [varchar](100) NOT NULL,
	[job_location_city] [varchar](100) NOT NULL,
	[job_location_state] [varchar](50) NOT NULL,
	[job_location_county] [varchar](50) NOT NULL,
	[job_location_zip] [int] NOT NULL,
	[job_location_active] [bit] NOT NULL,
 CONSTRAINT [PK_job_location_master_1] PRIMARY KEY CLUSTERED 
(
	[job_location_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[jobOpening_tbl]    Script Date: 14-May-2022 3:30:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[jobOpening_tbl](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[job_code] [varchar](20) NOT NULL,
	[job_title] [varchar](100) NOT NULL,
	[job_description] [varchar](max) NOT NULL,
	[job_postedDate] [datetime] NOT NULL,
	[job_closingDate] [datetime] NOT NULL,
	[job_active] [bit] NOT NULL,
	[job_location_id] [bigint] NOT NULL,
	[job_department_id] [int] NOT NULL,
 CONSTRAINT [PK_jobOpening_tbl] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
INSERT [dbo].[job_department_master] ([job_department_id], [job_department_title], [job_department_active]) VALUES (1, N'Project Management', 1)
INSERT [dbo].[job_department_master] ([job_department_id], [job_department_title], [job_department_active]) VALUES (2, N'Software development', 1)
INSERT [dbo].[job_department_master] ([job_department_id], [job_department_title], [job_department_active]) VALUES (3, N'Software testing', 1)
INSERT [dbo].[job_department_master] ([job_department_id], [job_department_title], [job_department_active]) VALUES (4, N'Business analysis', 1)
INSERT [dbo].[job_location_master] ([job_location_id], [job_location_title], [job_location_city], [job_location_state], [job_location_county], [job_location_zip], [job_location_active]) VALUES (1, N'US Office', N'Los angeles', N'California', N'US', 332422, 1)
INSERT [dbo].[job_location_master] ([job_location_id], [job_location_title], [job_location_city], [job_location_state], [job_location_county], [job_location_zip], [job_location_active]) VALUES (2, N'India', N'Panjim', N'Goa', N'India', 324233, 1)
INSERT [dbo].[job_location_master] ([job_location_id], [job_location_title], [job_location_city], [job_location_state], [job_location_county], [job_location_zip], [job_location_active]) VALUES (3, N'India', N'Karnataka', N'Bangalore', N'India', 32423, 1)
SET IDENTITY_INSERT [dbo].[jobOpening_tbl] ON 

INSERT [dbo].[jobOpening_tbl] ([id], [job_code], [job_title], [job_description], [job_postedDate], [job_closingDate], [job_active], [job_location_id], [job_department_id]) VALUES (1, N'JOB-00013', N'asdasdad', N'asdasdasd', CAST(0x0000AE8D01227869 AS DateTime), CAST(0x0000921C015A1D78 AS DateTime), 1, 1, 1)
INSERT [dbo].[jobOpening_tbl] ([id], [job_code], [job_title], [job_description], [job_postedDate], [job_closingDate], [job_active], [job_location_id], [job_department_id]) VALUES (2, N'JOB-00014', N'string', N'string', CAST(0x0000AE9200F6176E AS DateTime), CAST(0x0000AE92009B65A4 AS DateTime), 1, 0, 0)
INSERT [dbo].[jobOpening_tbl] ([id], [job_code], [job_title], [job_description], [job_postedDate], [job_closingDate], [job_active], [job_location_id], [job_department_id]) VALUES (3, N'JOB-00015', N'string', N'string', CAST(0x0000AE9200F6716E AS DateTime), CAST(0x0000AE92009B65A4 AS DateTime), 1, 0, 0)
INSERT [dbo].[jobOpening_tbl] ([id], [job_code], [job_title], [job_description], [job_postedDate], [job_closingDate], [job_active], [job_location_id], [job_department_id]) VALUES (4, N'JOB-00016', N'string', N'string', CAST(0x0000AE9200F6ABBA AS DateTime), CAST(0x0000AE92009BF6F4 AS DateTime), 1, 0, 0)
INSERT [dbo].[jobOpening_tbl] ([id], [job_code], [job_title], [job_description], [job_postedDate], [job_closingDate], [job_active], [job_location_id], [job_department_id]) VALUES (5, N'JOB-00018', N'asdasdad', N'asdasdasd', CAST(0x0000AE940172D4E2 AS DateTime), CAST(0x0000921C015A1D78 AS DateTime), 1, 1, 1)
INSERT [dbo].[jobOpening_tbl] ([id], [job_code], [job_title], [job_description], [job_postedDate], [job_closingDate], [job_active], [job_location_id], [job_department_id]) VALUES (6, N'JOB-00017', N'asdasdad', N'asdasdasd', CAST(0x0000AE9200F6E3B8 AS DateTime), CAST(0x0000921C015A1D78 AS DateTime), 1, 1, 1)
INSERT [dbo].[jobOpening_tbl] ([id], [job_code], [job_title], [job_description], [job_postedDate], [job_closingDate], [job_active], [job_location_id], [job_department_id]) VALUES (7, N'JOB-00019', N'sofware engineer', N'develop modules', CAST(0x0000AE940176FD03 AS DateTime), CAST(0x0000AE94015A1D78 AS DateTime), 1, 2, 3)
SET IDENTITY_INSERT [dbo].[jobOpening_tbl] OFF
ALTER TABLE [dbo].[job_department_master] ADD  CONSTRAINT [DF_job_department_master_job_location_active]  DEFAULT ((1)) FOR [job_department_active]
GO
ALTER TABLE [dbo].[job_location_master] ADD  CONSTRAINT [DF_job_location_master_job_location_active]  DEFAULT ((1)) FOR [job_location_active]
GO
ALTER TABLE [dbo].[jobOpening_tbl] ADD  CONSTRAINT [DF_jobOpening_tbl_job_location_active]  DEFAULT ((1)) FOR [job_active]
GO
USE [master]
GO
ALTER DATABASE [jobOpenings] SET  READ_WRITE 
GO
