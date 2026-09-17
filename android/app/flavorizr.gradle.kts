import com.android.build.gradle.AppExtension

val android = project.extensions.getByType(AppExtension::class.java)

android.apply {
    flavorDimensions("flavor-type")

    productFlavors {
        create("staging") {
            dimension = "flavor-type"
            applicationId = "com.iamutaki.sambasku.staging"
            resValue(type = "string", name = "app_name", value = "SambasKu Staging")
        }
        create("production") {
            dimension = "flavor-type"
            applicationId = "com.iamutaki.sambasku"
            resValue(type = "string", name = "app_name", value = "SambasKu")
        }
    }

    buildFeatures.resValues = true
}
