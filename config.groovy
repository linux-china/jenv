jenvVersion = '0.0.1'
environments {
	dev {
		jenvService = 'http://localhost:8080'
	}
	test {
		jenvService = 'http://test.jvmtool.mvnsearch.org'
	}
	prod {
		jenvService = 'http://get.jvmtool.mvnsearch.org'
	}
}
