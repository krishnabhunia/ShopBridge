CREATE DATABASE [db_ShopBridge];

GO

USE [db_ShopBridge]
GO
/****** Object:  StoredProcedure [dbo].[p_updateItem]    Script Date: 26-09-2021 20:44:46 ******/
DROP PROCEDURE IF EXISTS [dbo].[p_updateItem]
GO
/****** Object:  StoredProcedure [dbo].[p_deleteItem]    Script Date: 26-09-2021 20:44:46 ******/
DROP PROCEDURE IF EXISTS [dbo].[p_deleteItem]
GO
/****** Object:  StoredProcedure [dbo].[p_addItem]    Script Date: 26-09-2021 20:44:46 ******/
DROP PROCEDURE IF EXISTS [dbo].[p_addItem]
GO
/****** Object:  StoredProcedure [dbo].[list]    Script Date: 26-09-2021 20:44:46 ******/
DROP PROCEDURE IF EXISTS [dbo].[list]
GO
/****** Object:  Table [dbo].[product]    Script Date: 26-09-2021 20:44:46 ******/
DROP TABLE IF EXISTS [dbo].[product]
GO
USE [master]
GO
/****** Object:  Database [db_ShopBridge]    Script Date: 26-09-2021 20:44:46 ******/
DROP DATABASE IF EXISTS [db_ShopBridge]
GO
/****** Object:  Database [db_ShopBridge]    Script Date: 26-09-2021 20:44:46 ******/
CREATE DATABASE [db_ShopBridge]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'db_ShopBridge', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\db_ShopBridge.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'db_ShopBridge_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\db_ShopBridge_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO
ALTER DATABASE [db_ShopBridge] SET COMPATIBILITY_LEVEL = 150
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [db_ShopBridge].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [db_ShopBridge] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [db_ShopBridge] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [db_ShopBridge] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [db_ShopBridge] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [db_ShopBridge] SET ARITHABORT OFF 
GO
ALTER DATABASE [db_ShopBridge] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [db_ShopBridge] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [db_ShopBridge] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [db_ShopBridge] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [db_ShopBridge] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [db_ShopBridge] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [db_ShopBridge] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [db_ShopBridge] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [db_ShopBridge] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [db_ShopBridge] SET  DISABLE_BROKER 
GO
ALTER DATABASE [db_ShopBridge] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [db_ShopBridge] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [db_ShopBridge] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [db_ShopBridge] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [db_ShopBridge] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [db_ShopBridge] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [db_ShopBridge] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [db_ShopBridge] SET RECOVERY FULL 
GO
ALTER DATABASE [db_ShopBridge] SET  MULTI_USER 
GO
ALTER DATABASE [db_ShopBridge] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [db_ShopBridge] SET DB_CHAINING OFF 
GO
ALTER DATABASE [db_ShopBridge] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [db_ShopBridge] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [db_ShopBridge] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [db_ShopBridge] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
EXEC sys.sp_db_vardecimal_storage_format N'db_ShopBridge', N'ON'
GO
ALTER DATABASE [db_ShopBridge] SET QUERY_STORE = OFF
GO
USE [db_ShopBridge]
GO
/****** Object:  Table [dbo].[product]    Script Date: 26-09-2021 20:44:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[product](
	[product_id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](max) NOT NULL,
	[description] [nvarchar](max) NULL,
	[price] [money] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  StoredProcedure [dbo].[list]    Script Date: 26-09-2021 20:44:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[list] 
as
select * from product
GO
/****** Object:  StoredProcedure [dbo].[p_addItem]    Script Date: 26-09-2021 20:44:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[p_addItem] @name nvarchar(max), @desc nvarchar(max), @price money
as
insert into product
values(@name,@desc,@price)
GO
/****** Object:  StoredProcedure [dbo].[p_deleteItem]    Script Date: 26-09-2021 20:44:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[p_deleteItem] 
@product_id int
as
delete product
where product_id = @product_id
GO
/****** Object:  StoredProcedure [dbo].[p_updateItem]    Script Date: 26-09-2021 20:44:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[p_updateItem] 
@product_id int, @name nvarchar(max), @desc nvarchar(max), @price money
as
update product
set [name] = @name,
[description] = @desc,
[price] = @price
where product_id = @product_id
GO
USE [master]
GO
ALTER DATABASE [db_ShopBridge] SET  READ_WRITE 
GO
