Create database [Apple_iTunes]
GO


USE [Apple_iTunes]
GO
/****** Object:  Table [dbo].[album]    Script Date: 7/12/2025 1:53:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[album](
	[album_id] [int] NOT NULL,
	[title] [nvarchar](300) NOT NULL,
	[artist_id] [int] NOT NULL,
 CONSTRAINT [PK_album] PRIMARY KEY CLUSTERED 
(
	[album_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[artist]    Script Date: 7/12/2025 1:53:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[artist](
	[artist_id] [int] NOT NULL,
	[name] [nvarchar](200) NOT NULL,
 CONSTRAINT [PK_artist] PRIMARY KEY CLUSTERED 
(
	[artist_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[customer]    Script Date: 7/12/2025 1:53:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[customer](
	[customer_id] [int] NOT NULL,
	[first_name] [nvarchar](50) NOT NULL,
	[last_name] [nvarchar](50) NOT NULL,
	[company] [nvarchar](50) NULL,
	[address] [nvarchar](50) NOT NULL,
	[city] [nvarchar](50) NOT NULL,
	[state] [nvarchar](50) NULL,
	[country] [nvarchar](50) NOT NULL,
	[postal_code] [nvarchar](50) NULL,
	[phone] [nvarchar](50) NULL,
	[fax] [nvarchar](50) NULL,
	[email] [nvarchar](50) NOT NULL,
	[support_rep_id] [int] NOT NULL,
 CONSTRAINT [PK_customer] PRIMARY KEY CLUSTERED 
(
	[customer_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[employee]    Script Date: 7/12/2025 1:53:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[employee](
	[employee_id] [int] NOT NULL,
	[last_name] [nvarchar](50) NOT NULL,
	[first_name] [nvarchar](50) NOT NULL,
	[title] [nvarchar](50) NOT NULL,
	[reports_to] [int] NULL,
	[levels] [money] NOT NULL,
	[birthdate] [datetime2](7) NOT NULL,
	[hire_date] [datetime2](7) NOT NULL,
	[address] [nvarchar](50) NOT NULL,
	[city] [nvarchar](50) NOT NULL,
	[state] [nvarchar](50) NOT NULL,
	[country] [nvarchar](50) NOT NULL,
	[postal_code] [nvarchar](50) NOT NULL,
	[phone] [nvarchar](50) NOT NULL,
	[fax] [nvarchar](50) NOT NULL,
	[email] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_employee] PRIMARY KEY CLUSTERED 
(
	[employee_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[genre]    Script Date: 7/12/2025 1:53:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[genre](
	[genre_id] [int] NOT NULL,
	[name] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_genre] PRIMARY KEY CLUSTERED 
(
	[genre_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[invoice]    Script Date: 7/12/2025 1:53:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[invoice](
	[invoice_id] [int] NOT NULL,
	[customer_id] [int] NOT NULL,
	[invoice_date] [datetime2](7) NOT NULL,
	[billing_address] [nvarchar](50) NOT NULL,
	[billing_city] [nvarchar](50) NOT NULL,
	[billing_state] [nvarchar](50) NOT NULL,
	[billing_country] [nvarchar](50) NOT NULL,
	[billing_postal_code] [nvarchar](50) NOT NULL,
	[total] [float] NOT NULL,
 CONSTRAINT [PK_invoice] PRIMARY KEY CLUSTERED 
(
	[invoice_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[invoice_line]    Script Date: 7/12/2025 1:53:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[invoice_line](
	[invoice_line_id] [int] NOT NULL,
	[invoice_id] [int] NOT NULL,
	[track_id] [int] NOT NULL,
	[unit_price] [float] NOT NULL,
	[quantity] [tinyint] NOT NULL,
 CONSTRAINT [PK_invoice_line] PRIMARY KEY CLUSTERED 
(
	[invoice_line_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[media_type]    Script Date: 7/12/2025 1:53:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[media_type](
	[media_type_id] [int] NOT NULL,
	[name] [nvarchar](50) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[playlist]    Script Date: 7/12/2025 1:53:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[playlist](
	[playlist_id] [int] NOT NULL,
	[name] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_playlist] PRIMARY KEY CLUSTERED 
(
	[playlist_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[playlist_track]    Script Date: 7/12/2025 1:53:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[playlist_track](
	[playlist_id] [int] NOT NULL,
	[track_id] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[track]    Script Date: 7/12/2025 1:53:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[track](
	[track_id] [int] NOT NULL,
	[name] [nvarchar](500) NULL,
	[album_id] [int] NOT NULL,
	[media_type_id] [int] NOT NULL,
	[genre_id] [int] NOT NULL,
	[composer] [nvarchar](500) NULL,
	[milliseconds] [int] NOT NULL,
	[bytes] [int] NOT NULL,
	[unit_price] [float] NOT NULL,
 CONSTRAINT [PK_track] PRIMARY KEY CLUSTERED 
(
	[track_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[album]  WITH CHECK ADD FOREIGN KEY([artist_id])
REFERENCES [dbo].[artist] ([artist_id])
GO
ALTER TABLE [dbo].[customer]  WITH CHECK ADD FOREIGN KEY([support_rep_id])
REFERENCES [dbo].[employee] ([employee_id])
GO
ALTER TABLE [dbo].[employee]  WITH CHECK ADD FOREIGN KEY([reports_to])
REFERENCES [dbo].[employee] ([employee_id])
GO
ALTER TABLE [dbo].[playlist_track]  WITH CHECK ADD FOREIGN KEY([playlist_id])
REFERENCES [dbo].[playlist] ([playlist_id])
GO
ALTER TABLE [dbo].[playlist_track]  WITH CHECK ADD FOREIGN KEY([track_id])
REFERENCES [dbo].[track] ([track_id])
GO
