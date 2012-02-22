using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using System.Reflection;
using Dapper;

namespace ContinuousDelivery.WpfApplication
{
	public partial class MainWindow
	{
		public MainWindow()
		{
			InitializeComponent();
			var connectionString = ConfigurationManager.ConnectionStrings["database"].ConnectionString;
			var connectionStringDetails = connectionString.Split(';');
			var databaseServer = connectionStringDetails[0].Split('=')[1];
			var database = connectionStringDetails[1].Split('=')[1];
			var currentVersion = GetDatabaseVersion(connectionString);
			connectionDetails.Text = string.Format("Connected to database version {0} of {1}@{2}", currentVersion, database, databaseServer);
			assemblyVersion.Text = string.Format("Application version is {0}", Assembly.GetExecutingAssembly().GetName().Version);
		}

		private string GetDatabaseVersion(string connectionString)
		{
			string currentVersion;
			using (var connection = new SqlConnection(connectionString))
			{
				connection.Open();
				var version = connection.Query("select top 1 * from RoundhousE.Version order by id desc").First();
				currentVersion = version.version;
			}
			return currentVersion;
		}
	}
}